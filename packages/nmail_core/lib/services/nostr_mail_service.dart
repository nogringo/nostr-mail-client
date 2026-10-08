import 'dart:convert';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/domain_layer/entities/filter.dart' as ndk_filter;
import 'package:nostr_mail/nostr_mail.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/services/storage_service.dart';

const dmRelayListKind = 10050;
const blossomServerListKind = 10063;

/// NIP-37 relays for private content, listed encrypted in the content.
const privateRelayListKind = 10013;

/// NIP-62 request to vanish.
const vanishRequestKind = 62;

/// Sentinel [vanishRequestKind] relay tag asking every relay that receives the
/// request to honour it, not just the ones named in it.
const vanishAllRelays = 'ALL_RELAYS';

/// Information about email sync status from relays
class EmailSyncStatus {
  final String relayUrl;
  final DateTime oldest;
  final DateTime newest;

  const EmailSyncStatus({
    required this.relayUrl,
    required this.oldest,
    required this.newest,
  });
}

/// Owns the one [NostrMailClient] of the process. The client is account
/// agnostic: its managers read the logged account from ndk on every call and
/// its settings cache is keyed by pubkey, so an account change only detaches
/// and re-attaches it. Never dispose it: that closes the scheduler for good.
class NostrMailService {
  late final NostrMailClient client;

  final _storageService = GetIt.I<StorageService>();
  final _ndk = GetIt.I<Ndk>();

  bool get hasAccount => _ndk.accounts.getPublicKey() != null;

  /// Stream of relay connectivity changes. One entry per connection, and a
  /// relay reached under several identities has one connection each.
  Stream<List<RelayConnectivity>> get relayConnectivityChanges =>
      _ndk.connectivity.relayConnectivityChanges;

  Future<NostrMailService> init() async {
    client = await NostrMailClient.create(
      ndk: _ndk,
      database: GetIt.I<NostrMailDatabase>(),
      db: _storageService.db,
      blossomCache: GetIt.I<BlossomCache>(),
      syncEngine: GetIt.I<SyncEngine>(),
      broadcastQueue: GetIt.I<OfflineBroadcast>(),
      blossomUploadQueue: GetIt.I<OfflineBlossomUpload>(),
      schedulerDvm: NostrConfig.schedulerDvm,
      defaultDmRelays: NostrConfig.recommendedDmRelays,
    );
    return this;
  }

  /// Drops the relay subscriptions and the DVM listener of the account that is
  /// going away. Both restart on the next [activateForCurrentAccount].
  Future<void> resetForAccountChange() async {
    client.stopWatching();
    await client.stopScheduling();
  }

  /// Primes the private-settings cache so `cachedPrivateSettings` is readable
  /// synchronously right after an account becomes active.
  Future<void> activateForCurrentAccount() async {
    if (!hasAccount) return;
    await client.getLocalPrivateSettings();
  }

  String? getPublicKey() {
    return _ndk.accounts.getPublicKey();
  }

  Future<void> logout() async {
    await resetForAccountChange();
    _ndk.accounts.logout();
  }

  Future<void> clearLocalAccountData({required String pubkey}) {
    return client.clearLocalAccountData(pubkey: pubkey);
  }

  Future<void> clearAllLocalData() {
    return client.clearAllLocalData();
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

  /// Get the user's private relay list (kind 10013) from the outbox relays,
  /// falling back to the cache when none answers.
  ///
  /// Throws when the list cannot be known, so an edit never overwrites relays
  /// that were not read.
  Future<List<String>> getPrivateRelays() async {
    final account = _ndk.accounts.getLoggedAccount();
    if (account == null) return [];

    final response = _ndk.requests.query(
      name: 'private-relays',
      filter: ndk_filter.Filter(
        kinds: [privateRelayListKind],
        authors: [account.pubkey],
        limit: 1,
      ),
      explicitRelays: await getOutboxRelays(),
      timeout: const Duration(seconds: 5),
      cacheRead: false,
    );
    await response.future;
    final outcomes = await response.relayOutcomesDone;
    final anyRelayAnswered = outcomes.values.any(
      (outcome) => outcome.status == RelayRequestStatus.eose,
    );

    final events = await _ndk.config.cache.loadEvents(
      pubKeys: [account.pubkey],
      kinds: [privateRelayListKind],
    );
    if (events.isEmpty) {
      if (!anyRelayAnswered) {
        throw StateError('No relay answered the private relay list query');
      }
      return [];
    }

    final latestEvent = events.reduce(
      (a, b) => a.createdAt > b.createdAt ? a : b,
    );
    // The plaintext is kept per event id, so the signer is asked once per
    // version of the list.
    final privateTags = latestEvent.content.isEmpty
        ? const []
        : jsonDecode(
                (await _ndk.decryptedEventPayloads.loadOrDecrypt(
                  event: latestEvent,
                  viewerPubKey: account.pubkey,
                  scheme: DecryptedPayloadScheme.nip44,
                  decrypt: () => account.signer.decryptNip44(
                    ciphertext: latestEvent.content,
                    senderPubKey: account.pubkey,
                  ),
                ))!,
              )
              as List<dynamic>;

    return [
      for (final tag in [...latestEvent.tags, ...privateTags])
        if (tag is List && tag.length > 1 && tag[0] == 'relay')
          tag[1] as String,
    ];
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

  /// Mail coverage of the sync engine on the DM relays.
  Future<List<EmailSyncStatus>> getEmailSyncStatus() async {
    final pubkey = _ndk.accounts.getPublicKey();
    if (pubkey == null) return [];

    final dmRelays = await getDmRelays();

    // Must match nostr_mail's emailFilter, the engine files coverage under its
    // fingerprint.
    final states = await GetIt.I<SyncEngine>().coverageOfFilter(
      ndk_filter.Filter(kinds: [GiftWrap.kGiftWrapEventkind], pTags: [pubkey]),
      authPubkey: pubkey,
    );

    return states
        .where((state) => state.coverage.isNotEmpty)
        .where((state) => dmRelays.isEmpty || dmRelays.contains(state.relayUrl))
        .map(
          (state) => EmailSyncStatus(
            relayUrl: state.relayUrl,
            oldest: state.coverage.first.from,
            newest: state.coverage.last.to,
          ),
        )
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
}
