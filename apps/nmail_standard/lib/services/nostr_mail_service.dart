import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/domain_layer/entities/filter.dart' as ndk_filter;
import 'package:nostr_mail/nostr_mail.dart';

import '../app/config/nostr_config.dart';
import 'storage_service.dart';

const dmRelayListKind = 10050;
const blossomServerListKind = 10063;

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

class NostrMailService extends GetxService {
  NostrMailClient? _client;

  final _storageService = Get.find<StorageService>();
  final _ndk = Get.find<Ndk>();

  NostrMailClient get client {
    if (_client == null) {
      throw Exception(
        'NostrMailClient not initialized. Call initClient() first.',
      );
    }
    return _client!;
  }

  bool get isClientInitialized => _client != null;

  /// Stream of relay connectivity changes
  Stream<Map<String, RelayConnectivity>> get relayConnectivityChanges =>
      _ndk.connectivity.relayConnectivityChanges;

  Future<void> initClient() async {
    _client = await NostrMailClient.create(
      ndk: _ndk,
      db: _storageService.db,
      blossomCache: Get.find<BlossomCache>(),
      broadcastQueue: Get.find<OfflineBroadcast>(),
      blossomUploadQueue: Get.find<OfflineBlossomUpload>(),
      schedulerDvm: NostrConfig.schedulerDvm,
    );
  }

  String? getPublicKey() {
    return _ndk.accounts.getPublicKey();
  }

  Future<void> logout() async {
    await _client?.dispose();
    _client = null;
    _ndk.accounts.logout();
  }

  /// Returns the current user's NIP-65 outbox (write/readWrite) relays,
  /// falling back to [NostrConfig.bootstrapRelays] when none are set yet.
  Future<List<String>> getOutboxRelays() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return List<String>.from(NostrConfig.bootstrapRelays);

    final userRelayList = await _ndk.userRelayLists.getSingleUserRelayList(
      pubkey,
    );
    final outbox = userRelayList?.writeUrls.toList() ?? const [];
    return outbox.isNotEmpty
        ? outbox
        : List<String>.from(NostrConfig.bootstrapRelays);
  }

  /// Get the user's DM relay list (kind 10050) from local cache
  Future<List<String>> getDmRelays() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    final events = await _ndk.config.cache.loadEvents(
      pubKeys: [pubkey],
      kinds: [dmRelayListKind],
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

  /// Get the user's Blossom server list
  Future<List<String>> getBlossomServers() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    final servers = await _ndk.blossomUserServerList.getUserServerList(
      pubkeys: [pubkey],
    );

    return servers ?? [];
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

  // Email read/unread status methods using NIP-32 labels

  /// Check if an email is marked as read
  Future<bool> isEmailRead(String emailId) => client.isRead(emailId);

  /// Mark an email as read by adding 'state:read' label
  Future<void> markEmailAsRead(String emailId) => client.markAsRead(emailId);

  /// Mark an email as unread by removing 'state:read' label
  Future<void> markEmailAsUnread(String emailId) =>
      client.markAsUnread(emailId);

  /// Get all email IDs that are marked as read
  Future<Set<String>> getReadEmailIds() async {
    final list = await client.getReadEmailIds();
    return list.toSet();
  }
}
