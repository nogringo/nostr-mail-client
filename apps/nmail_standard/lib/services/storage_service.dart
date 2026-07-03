import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sembast_web/sembast_web.dart';

import 'storage_service_io.dart'
    if (dart.library.html) 'storage_service_stub.dart'
    as io;

class StorageService extends GetxService {
  late final Database db;
  bool _hasSeenOnboarding = false;

  bool get hasSeenOnboarding => _hasSeenOnboarding;

  static final _settingsStore = StoreRef<String, dynamic>('settings');

  Future<StorageService> init() async {
    if (kIsWeb) {
      db = await databaseFactoryWeb.openDatabase('nostr_mail');
    } else {
      db = await io.openDatabaseIo();
    }

    // Initialize cache
    _hasSeenOnboarding = await getSetting<bool>('has_seen_onboarding') ?? false;

    return this;
  }

  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsStore.record(key).put(db, value);
    if (key == 'has_seen_onboarding' && value is bool) {
      _hasSeenOnboarding = value;
    }
  }

  Future<T?> getSetting<T>(String key) async {
    return await _settingsStore.record(key).get(db) as T?;
  }

  Future<void> deleteSetting(String key) async {
    await _settingsStore.record(key).delete(db);
  }

  Future<void> clearAll() async {
    await _settingsStore.delete(db);
  }
}
