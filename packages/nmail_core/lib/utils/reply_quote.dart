import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:nostr_mail/nostr_mail.dart' show Email, htmlToText;

/// MIME text parts use CRLF. A `\r` left in a Quill document renders as an
/// extra line break, and on web the browser input rewrites it, which corrupts
/// the document.
String normalizeLineBreaks(String text) =>
    text.replaceAll(RegExp(r'\r\n?'), '\n');

/// The body as the reader shows it. Older Nmail versions put Markdown in the
/// text/plain part.
String quotableText(Email email) {
  final html = email.htmlBody;
  return html != null && html.isNotEmpty ? htmlToText(html) : email.body;
}

/// [header] followed by [body] as a blockquote, without `>` prefixes or
/// surrounding blank lines.
Delta replyQuoteDelta({required String header, required String body}) {
  final delta = Delta()..insert(header);
  final quotePrefix = RegExp(r'^(>+ ?)+');
  final text = normalizeLineBreaks(
    body,
  ).replaceFirst(RegExp(r'^\s*\n'), '').trimRight();
  for (final rawLine in text.split('\n')) {
    final line = rawLine.replaceFirst(quotePrefix, '');
    if (line.isNotEmpty) delta.insert(line);
    delta.insert('\n', {Attribute.blockQuote.key: true});
  }
  return delta..insert('\n');
}
