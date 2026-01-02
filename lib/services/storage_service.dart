import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sembast_web/sembast_web.dart';

import 'storage_service_io.dart'
    if (dart.library.html) 'storage_service_stub.dart'
    as io;

class StorageService extends GetxService {
  late final Database db;
  final _secureStorage = const FlutterSecureStorage();

  static const _privateKeyKey = 'nostr_private_key';

  Future<StorageService> init() async {
    if (kIsWeb) {
      db = await databaseFactoryWeb.openDatabase('nostr_mail');
    } else {
      db = await io.openDatabaseIo();
    }
    return this;
  }

  Future<void> savePrivateKey(String privateKey) async {
    await _secureStorage.write(key: _privateKeyKey, value: privateKey);
  }

  Future<String?> getPrivateKey() async {
    return _secureStorage.read(key: _privateKeyKey);
  }

  Future<void> deletePrivateKey() async {
    await _secureStorage.delete(key: _privateKeyKey);
  }

  Future<bool> hasPrivateKey() async {
    final key = await getPrivateKey();
    return key != null && key.isNotEmpty;
  }
}
