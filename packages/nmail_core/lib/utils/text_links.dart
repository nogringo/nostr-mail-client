enum TextSegmentKind { text, url, email }

typedef TextLinkSegment = ({String text, TextSegmentKind kind});

final _link = RegExp(
  r'(https?://[^\s<>"]+)|([A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+)',
  caseSensitive: false,
);
const _sentencePunctuation = '.,;:!?\'"';

/// Splits plain text into runs of text and the http(s) URLs and email
/// addresses between them.
List<TextLinkSegment> splitTextLinks(String text) {
  final segments = <TextLinkSegment>[];
  var start = 0;
  for (final match in _link.allMatches(text)) {
    final isUrl = match[1] != null;
    final link = isUrl ? _trimTrailing(match[0]!) : match[0]!;
    if (isUrl && (Uri.tryParse(link)?.host.isEmpty ?? true)) continue;
    if (match.start > start) {
      segments.add((
        text: text.substring(start, match.start),
        kind: TextSegmentKind.text,
      ));
    }
    segments.add((
      text: link,
      kind: isUrl ? TextSegmentKind.url : TextSegmentKind.email,
    ));
    start = match.start + link.length;
  }
  if (start < text.length) {
    segments.add((text: text.substring(start), kind: TextSegmentKind.text));
  }
  return segments;
}

/// Sentence punctuation and an unmatched `)` close the sentence, not the URL.
String _trimTrailing(String url) {
  var end = url.length;
  while (end > 0) {
    final last = url[end - 1];
    final unmatchedParen =
        last == ')' &&
        ')'.allMatches(url.substring(0, end)).length >
            '('.allMatches(url.substring(0, end)).length;
    if (!_sentencePunctuation.contains(last) && !unmatchedParen) break;
    end--;
  }
  return url.substring(0, end);
}
