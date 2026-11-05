import 'package:path/path.dart' as p;

/// Bidi overrides and isolates (U+202A-202E, U+2066-2069, LRM/RLM) can make
/// "fodne.pdf" render as "note.pdf"; the rest of the C0/C1 controls, path
/// separators and Windows-reserved names are rejected or defused too.
final _unsuitableChars = RegExp(
  '[\u0000-\u001f\u007f\u202a-\u202e\u2066-\u2069\u200e\u200f\u2028\u2029]',
);

final _windowsReserved = {
  'CON', 'PRN', 'AUX', 'NUL',
  'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
  'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9',
};

/// A filename an attachment may use on disk.
///
/// Derives from [name] but cannot traverse (separators replaced), cannot
/// spoof (bidi/controls stripped), cannot be empty, dot or dot-dot, keeps
/// Windows happy, and caps at 255 bytes of name.
String safeFilename(String name, {String fallback = 'attachment'}) {
  var s = name.replaceAll(_unsuitableChars, '');
  s = s.replaceAll(RegExp(r'[/\\]'), '_').trim();
  // Dot-only names before the leading-dot strip, so '.' and '..' land on the
  // fallback instead of a lonely underscore.
  if (s.isEmpty || s == '.' || s == '..') {
    s = fallback;
  }
  s = s.replaceAll(RegExp(r'^\.\.+'), '_');
  final ext = p.extension(s);
  if (s.length > 255) {
    final stem = s.substring(0, (255 - ext.length).clamp(1, 255).toInt());
    s = '$stem$ext';
  }
  if (_windowsReserved.contains(p.basenameWithoutExtension(s).toUpperCase())) {
    s = '_$s';
  }
  return s;
}
