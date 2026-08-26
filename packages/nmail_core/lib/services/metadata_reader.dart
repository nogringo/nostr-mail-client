import 'dart:async';

import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:rxdart/rxdart.dart';

import 'package:nmail_core/models/ndk_data_response.dart';
import 'package:nmail_core/models/relay_list_discovery_result.dart';
import 'package:nmail_core/services/relay_list_discovery.dart';

/// No relay answered, so the absence of a profile could not be concluded.
class MetadataUnreachable implements Exception {
  const MetadataUnreachable(this.pubkey);

  final String pubkey;

  @override
  String toString() => 'MetadataUnreachable: no relay answered for $pubkey';
}

/// Reads a profile (kind 0) from the author's own NIP-65 write relays.
///
/// Deliberately bypasses `ndk.metadata`: the RELAY_SETS engine, NDK's default,
/// does no NIP-65 routing on its read path, so without explicit relays a query
/// reaches the bootstrap relays only and a profile published on the author's
/// write relays is never found.
/// See https://github.com/relaystr/ndk/pull/698
class MetadataReader {
  MetadataReader(this._ndk, this._discovery);

  final Ndk _ndk;
  final RelayListDiscovery _discovery;

  NdkDataResponse<Metadata> read(String pubkey, {Duration? timeout}) {
    final subject = BehaviorSubject<NdkValue<Metadata>>();
    unawaited(_read(pubkey, subject, timeout));
    return NdkDataResponse(subject);
  }

  /// The relay-confirmed profile, or the cached one when the read concludes on
  /// cache. Throws [MetadataUnreachable] when absence could not be concluded.
  Future<Metadata?> load(String pubkey, {Duration? timeout}) async {
    final value = await read(pubkey, timeout: timeout).future;
    return value.value;
  }

  /// Reads many profiles at once, each from its own write relays.
  ///
  /// Cached profiles are returned without a network round trip, matching what
  /// `ndk.metadata.loadMetadatas` did: this feeds contact lists and recipient
  /// rows, where refining every already-known profile would cost far more than
  /// it is worth. Use [read] when a profile must be relay-confirmed.
  Future<Map<String, Metadata>> loadMany(
    List<String> pubkeys, {
    Duration? timeout,
  }) async {
    final result = <String, Metadata>{};
    final missing = <String>[];
    for (final pubkey in pubkeys.toSet()) {
      final cached = await _ndk.config.cache.loadMetadata(pubkey);
      if (cached != null) {
        result[pubkey] = cached;
      } else {
        missing.add(pubkey);
      }
    }
    if (missing.isEmpty) return result;

    final winners = <String, Nip01Event>{};
    void consider(Nip01Event event) {
      final current = winners[event.pubKey];
      if (current == null || _replaces(event, current)) {
        winners[event.pubKey] = event;
      }
    }

    final routed = await _routeByWriteRelay(missing);
    await Future.wait([
      for (final entry in routed.byRelay.entries)
        _collect(entry.value, [entry.key], timeout, consider),
      if (routed.unrouted.isNotEmpty)
        _collect(routed.unrouted, null, timeout, consider),
    ]);

    for (final entry in winners.entries) {
      final metadata = Metadata.fromEvent(entry.value);
      await _save(metadata, null);
      result[entry.key] = metadata;
    }
    return result;
  }

  Future<void> _collect(
    List<String> pubkeys,
    List<String>? relays,
    Duration? timeout,
    void Function(Nip01Event) consider,
  ) async {
    try {
      await for (final event in _ndk.requests
          .query(
            name: 'metadatas-outbox',
            filter: Filter(kinds: [Metadata.kKind], authors: pubkeys),
            explicitRelays: relays,
            timeout: timeout,
          )
          .stream) {
        consider(event);
      }
    } catch (_) {
      // One failing relay does not sink the batch.
    }
  }

  /// Groups authors by the relays worth asking, so the batch costs one query
  /// per relay instead of one per author.
  ///
  /// Only the first [_maxWriteRelaysPerAuthor] write relays of each author are
  /// used. NDK's own ranking picks the fewest relays covering the most authors;
  /// this is the cheap approximation, and it bounds the fan-out on a long
  /// contact list.
  Future<({Map<String, List<String>> byRelay, List<String> unrouted})>
  _routeByWriteRelay(List<String> pubkeys) async {
    final lists = <String, Map<String, ReadWriteMarker>>{};
    final unknown = <String>[];
    for (final pubkey in pubkeys) {
      final cached = await _ndk.config.cache.loadUserRelayList(pubkey);
      if (cached != null && _writeUrls(cached.relays) != null) {
        lists[pubkey] = cached.relays;
      } else {
        unknown.add(pubkey);
      }
    }

    for (final entry in (await _discovery.searchManyEverywhere(
      unknown,
    )).entries) {
      await _ndk.config.cache.saveUserRelayList(
        UserRelayList.fromNip65(Nip65.fromEvent(entry.value.event)),
      );
      lists[entry.key] = entry.value.relays;
    }

    final byRelay = <String, List<String>>{};
    final unrouted = <String>[];
    for (final pubkey in pubkeys) {
      final urls = _writeUrls(lists[pubkey]);
      if (urls == null) {
        unrouted.add(pubkey);
        continue;
      }
      for (final url in urls.take(_maxWriteRelaysPerAuthor)) {
        byRelay.putIfAbsent(url, () => []).add(pubkey);
      }
    }
    return (byRelay: byRelay, unrouted: unrouted);
  }

  static const _maxWriteRelaysPerAuthor = 3;

  Future<void> _read(
    String pubkey,
    BehaviorSubject<NdkValue<Metadata>> subject,
    Duration? timeout,
  ) async {
    Metadata? cached;
    try {
      cached = await _ndk.config.cache.loadMetadata(pubkey);
    } catch (_) {
      // An unreadable cache is not terminal.
    }
    subject.add(NdkValue.cache(cached));

    Nip01Event? winner;
    try {
      await for (final event in _ndk.requests
          .query(
            name: 'metadata-outbox',
            filter: Filter(
              kinds: [Metadata.kKind],
              authors: [pubkey],
              limit: 1,
            ),
            explicitRelays: await _writeRelays(pubkey),
            timeout: timeout,
          )
          .stream) {
        if (winner == null) {
          final known = cached?.updatedAt;
          if (known != null && event.createdAt < known) continue;
        } else if (!_replaces(event, winner)) {
          continue;
        }
        winner = event;
        subject.add(NdkValue.relays(Metadata.fromEvent(event)));
      }
    } catch (_) {
      // No answer. Whether that concludes anything is decided below.
    }

    if (winner != null) {
      await _save(Metadata.fromEvent(winner), cached);
    } else if (_discovery.relaysProvenDown) {
      subject.addError(MetadataUnreachable(pubkey));
    } else {
      subject.add(const NdkValue<Metadata>.relays(null));
    }
    await subject.close();
  }

  /// NIP-01 replacement ordering: newest wins, ties broken by lowest id.
  bool _replaces(Nip01Event candidate, Nip01Event current) {
    if (candidate.createdAt != current.createdAt) {
      return candidate.createdAt > current.createdAt;
    }
    return candidate.id.compareTo(current.id) < 0;
  }

  Future<void> _save(Metadata metadata, Metadata? cached) async {
    final known = cached?.updatedAt;
    if (known != null && (metadata.updatedAt ?? 0) <= known) return;
    metadata.refreshedTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _ndk.config.cache.saveMetadata(metadata);
  }

  /// Null falls back to NDK's own routing, which is the bootstrap relays.
  Future<List<String>?> _writeRelays(String pubkey) async {
    final cached = await _ndk.config.cache.loadUserRelayList(pubkey);
    final known = _writeUrls(cached?.relays);
    if (known != null) return known;

    final found = await _discovery.searchEverywhere(pubkey);
    if (found is! RelayListFound) return null;

    await _ndk.config.cache.saveUserRelayList(
      UserRelayList.fromNip65(Nip65.fromEvent(found.event)),
    );
    return _writeUrls(found.relays);
  }

  List<String>? _writeUrls(Map<String, ReadWriteMarker>? relays) {
    if (relays == null) return null;
    final urls = relays.entries
        .where((entry) => entry.value.isWrite)
        .map((entry) => entry.key)
        .toList();
    return urls.isEmpty ? null : urls;
  }
}
