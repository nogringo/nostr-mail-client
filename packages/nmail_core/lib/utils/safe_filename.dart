import 'dart:convert';

import 'package:path/path.dart' as p;

final _controlAndBidiChars = RegExp(
  r'[\x00-\x1f\x7f-\x9f\u061c\u200e\u200f\u2028\u2029\u202a-\u202e\u2066-\u2069]',
);
final _pathReservedChars = RegExp(r'[<>:"/\\|?*]');
final _trailingDotsAndSpaces = RegExp(r'[. ]+$');
const _maxBytes = 255;

/// [name] fit to display and to write to disk, or null when nothing is left.
String? safeFilename(String? name) {
  final cleaned = (name ?? '')
      .replaceAll(_controlAndBidiChars, '')
      .replaceAll(_pathReservedChars, '_')
      .trim()
      .replaceFirst(_trailingDotsAndSpaces, '');
  if (cleaned.isEmpty) return null;
  if (utf8.encode(cleaned).length <= _maxBytes) return cleaned;

  final extension = p.extension(cleaned);
  final extensionBytes = utf8.encode(extension).length;
  if (extensionBytes >= _maxBytes) return _truncateUtf8(cleaned, _maxBytes);
  final stem = cleaned.substring(0, cleaned.length - extension.length);
  return _truncateUtf8(stem, _maxBytes - extensionBytes) + extension;
}

String _truncateUtf8(String s, int maxBytes) {
  final out = StringBuffer();
  var bytes = 0;
  for (final rune in s.runes) {
    bytes += utf8.encode(String.fromCharCode(rune)).length;
    if (bytes > maxBytes) break;
    out.writeCharCode(rune);
  }
  return out.toString();
}
