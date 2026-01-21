import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

Future<Database> openDatabaseIo() async {
  final dir = await getApplicationSupportDirectory();
  final dbName = kDebugMode ? 'nostr_mail_dev.db' : 'nostr_mail.db';
  final dbPath = p.join(dir.path, dbName);
  return databaseFactoryIo.openDatabase(dbPath);
}
