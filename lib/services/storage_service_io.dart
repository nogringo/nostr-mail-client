import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openDatabaseIo() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbDir = Directory('${dir.path}/nostr_mail');
  if (!await dbDir.exists()) {
    await dbDir.create(recursive: true);
  }
  final dbPath = '${dbDir.path}/nostr_mail.db';
  return databaseFactoryIo.openDatabase(dbPath);
}
