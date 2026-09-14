import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

/// MIME text parts use CRLF. A `\r` left in a Quill document renders as an
/// extra line break, and on web the browser input rewrites it, which corrupts
/// the document.
String normalizeLineBreaks(String text) =>
    text.replaceAll(RegExp(r'\r\n?'), '\n');

/// [header] followed by [body] as a blockquote, without `>` prefixes or
/// trailing blank lines.
Delta replyQuoteDelta({required String header, required String body}) {
  final delta = Delta()..insert(header);
  final quotePrefix = RegExp(r'^(>+ ?)+');
  for (final rawLine in normalizeLineBreaks(body).trimRight().split('\n')) {
    final line = rawLine.replaceFirst(quotePrefix, '');
    if (line.isNotEmpty) delta.insert(line);
    delta.insert('\n', {Attribute.blockQuote.key: true});
  }
  return delta..insert('\n');
}
