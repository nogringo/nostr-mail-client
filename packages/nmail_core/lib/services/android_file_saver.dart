import 'package:flutter/services.dart';

class AndroidFileSaver {
  static const platform = MethodChannel('app.nostrmail.client/native');

  static Future<String> saveToDownloads({
    required String fileName,
    required Uint8List bytes,
    String? mimeType,
  }) async {
    try {
      final result = await platform.invokeMethod('saveToDownloads', {
        'fileName': fileName,
        'bytes': bytes,
        'mimeType': mimeType ?? 'application/octet-stream',
      });
      return result as String;
    } on PlatformException catch (e) {
      throw Exception('Failed to save file: ${e.message}');
    }
  }
}
