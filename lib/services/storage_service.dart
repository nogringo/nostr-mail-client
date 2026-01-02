import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class StorageService extends GetxService {
  late final Database db;
  final _secureStorage = const FlutterSecureStorage();

  static const _privateKeyKey = 'nostr_private_key';

  Future<StorageService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbDir = Directory('${dir.path}/nostr_mail');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final dbPath = '${dbDir.path}/nostr_mail.db';
    db = await databaseFactoryIo.openDatabase(dbPath);
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
