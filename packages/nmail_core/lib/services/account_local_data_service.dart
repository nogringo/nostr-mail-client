import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import '../models/background_preset.dart';
import 'address_book_service.dart';
import 'metadata_service.dart';
import 'nostr_mail_service.dart';
import 'push_subscription_service.dart';
import 'storage_service.dart';

class AccountLocalDataService extends GetxService {
  static const _backgroundImageKey = 'background_image';

  final _storageService = Get.find<StorageService>();

  Future<void> clearLocalAccountData({required String pubkey}) async {
    await Future.wait([
      if (Get.isRegistered<NostrMailService>())
        Get.find<NostrMailService>().clearLocalAccountData(pubkey: pubkey),
      if (Get.isRegistered<AddressBookService>())
        Get.find<AddressBookService>().clearLocalAccountData(pubkey: pubkey),
      if (GetIt.I.isRegistered<OfflineBroadcast>())
        GetIt.I<OfflineBroadcast>().clearLocalAccountData(pubkey: pubkey),
      if (GetIt.I.isRegistered<OfflineBlossomUpload>())
        GetIt.I<OfflineBlossomUpload>().clearLocalAccountData(pubkey: pubkey),
      _clearNdkCache(pubkey),
      _clearAccountSettings(pubkey),
    ]);
  }

  /// Drops what the ndk cache holds about [pubkey]: the events it signed, the
  /// gift wraps addressed to it, and the records derived from them. Without
  /// this the account's own notes, contacts, profile and received mail outlive
  /// its removal and are served straight back from cache the next time the
  /// same key logs in.
  Future<void> _clearNdkCache(String pubkey) async {
    if (!GetIt.I.isRegistered<Ndk>()) return;

    final cache = GetIt.I<Ndk>().config.cache;
    await Future.wait([
      cache.removeAllEventsByPubKey(pubkey),
      // Gift wraps carry an ephemeral author, so the recipient p tag is the
      // only thing tying them to this account.
      cache.removeEvents(
        kinds: [GiftWrap.kGiftWrapEventkind],
        tags: {
          'p': [pubkey],
        },
      ),
      cache.removeEvents(pubKeys: [pubkey], kinds: [Metadata.kKind]),
      cache.removeUserRelayList(pubkey),
      cache.removeEvents(pubKeys: [pubkey], kinds: [ContactList.kKind]),
      cache.removeNip05(pubkey),
    ]);

    if (Get.isRegistered<MetadataService>()) {
      Get.find<MetadataService>().forget(pubkey);
    }
  }

  Future<void> clearAllLocalData() async {
    await Future.wait([
      if (Get.isRegistered<NostrMailService>())
        Get.find<NostrMailService>().clearAllLocalData(),
      if (Get.isRegistered<AddressBookService>())
        Get.find<AddressBookService>().clearAllLocalData(),
      if (GetIt.I.isRegistered<OfflineBroadcast>())
        GetIt.I<OfflineBroadcast>().clearAllLocalData(),
      if (GetIt.I.isRegistered<OfflineBlossomUpload>())
        GetIt.I<OfflineBlossomUpload>().clearAllLocalData(),
      if (GetIt.I.isRegistered<BlossomCache>())
        GetIt.I<BlossomCache>().clearAllLocalData(),
    ]);
    // After the packages: they release their sync requests, which the engine
    // would otherwise walk straight back into the cache being cleared.
    if (GetIt.I.isRegistered<SyncEngine>()) {
      await GetIt.I<SyncEngine>().clearAllLocalData();
    }
    if (GetIt.I.isRegistered<Ndk>()) {
      await GetIt.I<Ndk>().config.cache.clearAll();
    }
    await _storageService.clearAll();
  }

  /// Deletes a background from the Blossom cache once no account on this
  /// device shows it anymore.
  Future<void> _releaseCachedBackground(String? value) async {
    final sha256 = BackgroundPreset.cachedImageSha256(value);
    if (sha256 == null || !GetIt.I.isRegistered<BlossomCache>()) return;

    for (final pubkey in GetIt.I<Ndk>().accounts.accounts.keys) {
      final background = await _storageService.getSetting<String>(
        '${_backgroundImageKey}_$pubkey',
      );
      if (background == value) return;
    }
    await GetIt.I<BlossomCache>().delete(sha256);
  }

  Future<void> _clearAccountSettings(String pubkey) async {
    final backgroundKey = '${_backgroundImageKey}_$pubkey';
    final background = await _storageService.getSetting<String>(backgroundKey);
    await _storageService.deleteSetting(backgroundKey);
    await _releaseCachedBackground(background);

    await _storageService.deleteSetting(
      PushSubscriptionService.enabledKey(pubkey),
    );
    await _storageService.deleteSetting(
      PushSubscriptionService.registrationKey(pubkey),
    );
  }
}
