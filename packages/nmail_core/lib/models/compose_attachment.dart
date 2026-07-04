import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Represents an attachment being composed
class ComposeAttachment {
  final String filename;
  final Uint8List data;
  final String mimeType;

  const ComposeAttachment({
    required this.filename,
    required this.data,
    required this.mimeType,
  });

  /// Get file size in bytes
  int get size => data.length;

  /// Get file extension
  String get extension => p.extension(filename).toLowerCase();
}
