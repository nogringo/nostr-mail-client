import 'dart:typed_data';

Future<void> writeFileToDirectory(
  String directory,
  String filename,
  Uint8List bytes,
) => throw UnsupportedError('No file system on the web');
