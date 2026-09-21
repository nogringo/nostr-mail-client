final _homePathPatterns = [
  RegExp(r'(/Users/)[^/\s]+'),
  RegExp(r'(/home/)[^/\s]+'),
  RegExp(r'([A-Za-z]:\\Users\\)[^\\\s]+'),
];

/// Replaces the account name in home directory paths, which is the one piece
/// of a crash report that identifies the person running it.
String redactHomePaths(String text) {
  var redacted = text;
  for (final pattern in _homePathPatterns) {
    redacted = redacted.replaceAllMapped(pattern, (match) => '${match[1]}user');
  }
  return redacted;
}
