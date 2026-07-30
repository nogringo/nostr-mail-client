import 'dart:io';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'address_book_service.dart';
import 'nostr_mail_service.dart';
import 'storage_service.dart';

class AccountLocalDataService extends GetxService {
  static const _backgroundImageKey = 'background_image';
  static const _backgroundsDirName = 'backgrounds';

  final _storageService = Get.find<StorageService>();

  Future<void> clearLocalAccountData({required String pubkey}) async {
    await Future.wait([
      if (Get.isRegistered<NostrMailService>())
        Get.find<NostrMailService>().clearLocalAccountData(pubkey: pubkey),
      if (Get.isRegistered<AddressBookService>())
        Get.find<AddressBookService>().clearLocalAccountData(pubkey: pubkey),
      if (Get.isRegistered<OfflineBroadcast>())
        Get.find<OfflineBroadcast>().clearLocalAccountData(pubkey: pubkey),
      if (Get.isRegistered<OfflineBlossomUpload>())
        Get.find<OfflineBlossomUpload>().clearLocalAccountData(pubkey: pubkey),
      _clearAccountSettings(pubkey),
    ]);
  }

  Future<void> clearAllLocalData() async {
    await Future.wait([
      if (Get.isRegistered<NostrMailService>())
        Get.find<NostrMailService>().clearAllLocalData(),
      if (Get.isRegistered<AddressBookService>())
        Get.find<AddressBookService>().clearAllLocalData(),
      if (Get.isRegistered<OfflineBroadcast>())
        Get.find<OfflineBroadcast>().clearAllLocalData(),
      if (Get.isRegistered<OfflineBlossomUpload>())
        Get.find<OfflineBlossomUpload>().clearAllLocalData(),
      if (Get.isRegistered<BlossomCache>())
        Get.find<BlossomCache>().clearAllLocalData(),
    ]);
    if (Get.isRegistered<Ndk>()) {
      await Get.find<Ndk>().config.cache.clearAll();
    }
    await _storageService.clearAll();
    await _deleteBackgroundsDirectory();
  }

  Future<void> _clearAccountSettings(String pubkey) async {
    final backgroundKey = '${_backgroundImageKey}_$pubkey';
    final backgroundPath = await _storageService.getSetting<String>(
      backgroundKey,
    );
    await _storageService.deleteSetting(backgroundKey);
    await _deleteBackgroundFile(backgroundPath);
  }

  Future<void> _deleteBackgroundFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final backgroundsDir = await _backgroundsDirectory();
      final file = File(imagePath);
      if (await file.exists() && p.isWithin(backgroundsDir.path, file.path)) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> _deleteBackgroundsDirectory() async {
    try {
      final backgroundsDir = await _backgroundsDirectory();
      if (await backgroundsDir.exists()) {
        await backgroundsDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  Future<Directory> _backgroundsDirectory() async {
    final appDir = await getApplicationSupportDirectory();
    return Directory(p.join(appDir.path, _backgroundsDirName));
  }
}
