import 'dart:io';
import 'dart:typed_data';

import 'package:nmail_core/utils/unique_filename.dart';
import 'package:path/path.dart' as p;

Future<void> writeFileToDirectory(
  String directory,
  String filename,
  Uint8List bytes,
) async {
  final name = uniqueFilename(
    filename,
    (candidate) => File(p.join(directory, candidate)).existsSync(),
  );
  await File(p.join(directory, name)).writeAsBytes(bytes, flush: true);
}
