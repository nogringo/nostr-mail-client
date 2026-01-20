import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
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

  /// Get the user's DM relay list (kind 10050)
  Future<List<String>> getDmRelays() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    final response = _ndk.requests.query(
      filter: ndk_filter.Filter(kinds: [_dmRelayListKind], authors: [pubkey]),
    );

    Nip01Event? latestEvent;
    await for (final event in response.stream) {
      if (latestEvent == null || event.createdAt > latestEvent.createdAt) {
        latestEvent = event;
      }
    }

    if (latestEvent == null) return [];

    final List<String> relays = [];
    for (final tag in latestEvent.tags) {
      if (tag.isNotEmpty && tag[0] == 'relay' && tag.length > 1) {
        relays.add(tag[1]);
      }
    }

    return relays;
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
