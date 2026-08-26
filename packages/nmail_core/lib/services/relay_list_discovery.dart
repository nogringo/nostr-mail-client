import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/models/relay_list_discovery_result.dart';
import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/utils/relay_utils.dart';

/// Searches the network for a user's NIP-65 relay list (kind 10002).
///
/// Deliberately bypasses `ndk.userRelayLists`: that one reads the cache first,
/// gives no control over which relays are queried, and silently falls back to
/// the kind 3 contact list, which is not a NIP-65 list.
class RelayListDiscovery {
  final Ndk _ndk;
  final DeviceConnectivityService? _device;

  /// Observed for the whole lifetime of the instance, not just during a query:
  /// a single query window can be too narrow to catch an emission, and telling
  /// "no list" from "no network" hangs on this map.
  StreamSubscription<Map<String, RelayConnectivity>>? _connectivitySub;
  Map<String, RelayConnectivity>? _connectivity;

  RelayListDiscovery(this._ndk, {this._device}) {
    _connectivitySub = _ndk.connectivity.relayConnectivityChanges.listen(
      (map) => _connectivity = map,
    );
  }

  void dispose() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Observed at least once, and nothing was up. A map still unset means "not
  /// known yet", which is not the same as "nothing is connected": NDK fills it
  /// the moment it starts dialling, so waiting for it costs nothing.
  bool get relaysProvenDown {
    final observed = _connectivity;
    return observed != null && !observed.values.any((c) => c.isConnected);
  }

  static const _relayListKind = 10002;

  /// Every relay worth asking, in one pass: the ones the account is likely to
  /// have published to, plus the ones that index kind 10002 network-wide.
  ///
  /// One pass rather than two, because a query resolves only once every relay
  /// has sent its EOSE, never on the first hit. Splitting it would pay the
  /// slowest relay twice for no extra coverage.
  Future<RelayListDiscoveryResult> searchEverywhere(String pubkey) {
    return searchOn(
      pubkey,
      {
        ...NostrConfig.bootstrapRelays,
        ...NostrConfig.popularRelays,
        ...NostrConfig.discoveryRelays,
      }.toList(),
    );
  }

  Future<RelayListDiscoveryResult> searchOn(
    String pubkey,
    List<String> relays, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (relays.isEmpty) return const RelayListUnreachable();

    // Skip the timeout when every signal agrees there is nothing to reach. The
    // OS verdict alone would not do: on Linux and Windows it comes from an
    // internet probe a firewall can fail, and a local relay answers with no
    // internet at all.
    if (_device?.isOffline.value == true &&
        relaysProvenDown &&
        !relays.any(isLocalRelayUrl)) {
      return const RelayListUnreachable();
    }

    List<Nip01Event> events;
    try {
      final response = _ndk.requests.query(
        filter: Filter(kinds: [_relayListKind], authors: [pubkey], limit: 1),
        explicitRelays: relays,
        cacheRead: false,
      );
      events = await response.future.timeout(
        timeout,
        onTimeout: () => const [],
      );
    } catch (_) {
      events = const [];
    }

    if (events.isNotEmpty) {
      final latest = events.reduce((a, b) => a.createdAt > b.createdAt ? a : b);
      final nip65 = Nip65.fromEvent(latest);
      if (nip65.relays.isNotEmpty) {
        return RelayListFound(event: latest, relays: nip65.relays);
      }
    }

    // An empty result only means "no list" if something actually answered.
    if (relaysProvenDown) return const RelayListUnreachable();
    return const RelayListMissing();
  }

  /// The lists found for [pubkeys], in one query rather than one per pubkey.
  ///
  /// A pubkey is simply absent from the result when nothing was found for it;
  /// [relaysProvenDown] tells "no list" from "no network" for the batch as a
  /// whole. Carries no `limit`, which with several authors would cap the whole
  /// relay response rather than each author's newest event.
  Future<Map<String, RelayListFound>> searchManyEverywhere(
    List<String> pubkeys, {
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (pubkeys.isEmpty) return const {};

    final relays = {
      ...NostrConfig.bootstrapRelays,
      ...NostrConfig.popularRelays,
      ...NostrConfig.discoveryRelays,
    }.toList();

    if (_device?.isOffline.value == true &&
        relaysProvenDown &&
        !relays.any(isLocalRelayUrl)) {
      return const {};
    }

    List<Nip01Event> events;
    try {
      final response = _ndk.requests.query(
        filter: Filter(kinds: [_relayListKind], authors: pubkeys),
        explicitRelays: relays,
        cacheRead: false,
      );
      events = await response.future.timeout(timeout, onTimeout: () => const []);
    } catch (_) {
      events = const [];
    }

    final latest = <String, Nip01Event>{};
    for (final event in events) {
      final current = latest[event.pubKey];
      if (current == null || event.createdAt > current.createdAt) {
        latest[event.pubKey] = event;
      }
    }

    final found = <String, RelayListFound>{};
    for (final entry in latest.entries) {
      final nip65 = Nip65.fromEvent(entry.value);
      if (nip65.relays.isEmpty) continue;
      found[entry.key] = RelayListFound(
        event: entry.value,
        relays: nip65.relays,
      );
    }
    return found;
  }

  /// Caches the found list so every reader picks it up, and rebroadcasts the
  /// event untouched so the next app on the next device finds it too.
  Future<void> adopt(RelayListFound found) async {
    final userRelayList = UserRelayList.fromNip65(Nip65.fromEvent(found.event));
    await _ndk.config.cache.saveUserRelayList(userRelayList);
    await Get.find<OfflineBroadcast>().broadcast(
      found.event,
      relays: {
        ...NostrConfig.popularRelays,
        ...NostrConfig.discoveryRelays,
      }.toList(),
      pubkey: found.event.pubKey,
    );
  }
}
