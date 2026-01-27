import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/domain_layer/entities/filter.dart' as ndk_filter;
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';

import 'storage_service.dart';

/// Information about email sync status from relays
class EmailSyncStatus {
  final String relayUrl;
  final int? oldestTimestamp;
  final int? newestTimestamp;

  const EmailSyncStatus({
    required this.relayUrl,
    this.oldestTimestamp,
    this.newestTimestamp,
  });
}

const _dmRelayListKind = 10050;

class NostrMailService extends GetxService {
  NostrMailClient? _client;
  late Ndk _ndk;

  final _storageService = Get.find<StorageService>();

  NostrMailClient get client {
    if (_client == null) {
      throw Exception(
        'NostrMailClient not initialized. Call initClient() first.',
      );
    }
    return _client!;
  }

  Ndk get ndk => _ndk;

  bool get isClientInitialized => _client != null;

  /// Stream of relay connectivity changes
  Stream<Map<String, RelayConnectivity>> get relayConnectivityChanges =>
      _ndk.connectivity.relayConnectivityChanges;

  Future<void> initNdk() async {
    final cacheManager = SembastCacheManager(_storageService.db);

    _ndk = Ndk(
      NdkConfig(
        eventVerifier: kIsWeb ? Bip340EventVerifier() : RustEventVerifier(),
        cache: cacheManager,
        bootstrapRelays: [
          'wss://relay.damus.io',
          'wss://nos.lol',
          'wss://relay.nostr.band',
          'wss://relay.primal.net',
          'wss://relay.coinos.io',
          'wss://nostr-01.uid.ovh',
          'wss://nostr-02.uid.ovh',
          'wss://nostr-01.yakihonne.com',
        ],
        fetchedRangesEnabled: true,
      ),
    );
  }

  void initClient() {
    _client = NostrMailClient(ndk: _ndk, db: _storageService.db);
  }

  String? getPublicKey() {
    return _ndk.accounts.getPublicKey();
  }

  Future<void> logout() async {
    _ndk.accounts.logout();
    _client = null;
  }

  /// Get the user's DM relay list (kind 10050) from local cache
  Future<List<String>> getDmRelays() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    final events = await _ndk.config.cache.loadEvents(
      pubKeys: [pubkey],
      kinds: [_dmRelayListKind],
    );

    if (events.isEmpty) return [];

    // Get the most recent event
    final latestEvent = events.reduce(
      (a, b) => a.createdAt > b.createdAt ? a : b,
    );

    final List<String> relays = [];
    for (final tag in latestEvent.tags) {
      if (tag.isNotEmpty && tag[0] == 'relay' && tag.length > 1) {
        relays.add(tag[1]);
      }
    }

    return relays;
  }

  /// Save DM relays list (kind 10050) to local cache and broadcast to network
  Future<void> saveDmRelays(List<String> relays) async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return;

    final event = Nip01Event(
      pubKey: pubkey,
      kind: _dmRelayListKind,
      tags: relays.map((r) => ['relay', r]).toList(),
      content: '',
    );

    // Save to local cache first
    await _ndk.config.cache.saveEvent(event);

    // Then broadcast to network
    final broadcast = _ndk.broadcast.broadcast(nostrEvent: event);
    await broadcast.broadcastDoneFuture;
  }

  /// Get the user's Blossom server list
  Future<List<String>> getBlossomServers() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    final servers = await _ndk.blossomUserServerList.getUserServerList(
      pubkeys: [pubkey],
    );

    return servers ?? [];
  }

  /// Save Blossom server list and broadcast to network
  Future<void> saveBlossomServers(List<String> servers) async {
    await _ndk.blossomUserServerList.publishUserServerList(
      serverUrlsOrdered: servers,
    );
  }

  /// Get the user's NIP-65 relay list (kind 10002)
  Future<Map<String, ReadWriteMarker>> getNip65Relays() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return {};

    final userRelayList = await _ndk.userRelayLists.getSingleUserRelayList(
      pubkey,
    );

    return userRelayList?.relays ?? {};
  }

  /// Save NIP-65 relay list and broadcast to network
  Future<void> saveNip65Relays(Map<String, ReadWriteMarker> relays) async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final userRelayList = UserRelayList(
      pubKey: pubkey,
      relays: relays,
      createdAt: now,
      refreshedTimestamp: now,
    );

    await _ndk.userRelayLists.setInitialUserRelayList(userRelayList);
  }

  /// Get sync status for emails from DM relays only using fetchedRanges
  Future<List<EmailSyncStatus>> getEmailSyncStatus() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    // Get user's DM relays
    final dmRelays = await getDmRelays();

    // Build the same filter used for fetching emails (gift wraps for this user)
    final filter = ndk_filter.Filter(
      kinds: [GiftWrap.kGiftWrapEventkind],
      pTags: [pubkey],
    );

    final fetchedRangesMap = await _ndk.fetchedRanges.getForFilter(filter);

    // Filter to only show DM relays
    return fetchedRangesMap.entries
        .where((entry) => dmRelays.isEmpty || dmRelays.contains(entry.key))
        .map((entry) {
          final relayRanges = entry.value;
          return EmailSyncStatus(
            relayUrl: entry.key,
            oldestTimestamp: relayRanges.oldest,
            newestTimestamp: relayRanges.newest,
          );
        })
        .toList();
  }
}
