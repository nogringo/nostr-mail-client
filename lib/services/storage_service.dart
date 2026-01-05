import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sembast_web/sembast_web.dart';

import 'storage_service_io.dart'
    if (dart.library.html) 'storage_service_stub.dart'
    as io;

class StorageService extends GetxService {
  late final Database db;

  static final _settingsStore = StoreRef<String, dynamic>('settings');

  Future<StorageService> init() async {
    if (kIsWeb) {
      db = await databaseFactoryWeb.openDatabase('nostr_mail');
    } else {
      db = await io.openDatabaseIo();
    }
    return this;
  }

  // Settings methods
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsStore.record(key).put(db, value);
  }

  Future<T?> getSetting<T>(String key) async {
    return await _settingsStore.record(key).get(db) as T?;
  }
}
