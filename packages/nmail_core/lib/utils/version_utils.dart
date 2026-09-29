import 'dart:math';

/// Compares dotted numeric versions, ignoring a leading `v` and any
/// `-prerelease` or `+build` suffix. Unparsable input is never newer.
bool isNewerVersion(String candidate, String current) {
  final a = _parseVersion(candidate);
  final b = _parseVersion(current);
  if (a == null || b == null) return false;

  for (var i = 0; i < max(a.length, b.length); i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

List<int>? _parseVersion(String version) {
  final core = version
      .trim()
      .replaceFirst(RegExp('^v'), '')
      .split(RegExp('[-+]'))
      .first;
  final parts = core.split('.').map(int.tryParse).toList();
  if (parts.contains(null)) return null;
  return parts.cast<int>();
}
