import 'dart:io';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:idb_sqflite/idb_sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool _ffiInitialized = false;

Future<BlossomCache> createBlossomCache() async {
  late final IdbFactory factory;

  if (Platform.isAndroid || Platform.isIOS) {
    factory = getIdbFactorySqflite(sqflite.databaseFactory);
  } else {
    if (!_ffiInitialized) {
      sqfliteFfiInit();
      _ffiInitialized = true;
    }
    final appSupportDir = await getApplicationSupportDirectory();
    final blossomDbDir = Directory(p.join(appSupportDir.path, 'blossom_cache'));
    await blossomDbDir.create(recursive: true);
    await databaseFactoryFfi.setDatabasesPath(blossomDbDir.path);
    factory = getIdbFactorySqflite(databaseFactoryFfi);
  }

  return IdbBlossomCache.open(factory: factory);
}
