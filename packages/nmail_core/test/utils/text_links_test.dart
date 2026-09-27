import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/text_links.dart';

List<String> _links(String text) => [
  for (final s in splitTextLinks(text))
    if (s.kind != TextSegmentKind.text) s.text,
];

void main() {
  group('splitTextLinks', () {
    test('keeps every character, in order', () {
      const text = 'Go to https://a.com/x now.\r\nThen http://b.org';
      expect(splitTextLinks(text).map((s) => s.text).join(), text);
    });

    test('is one text run when there is no URL', () {
      expect(splitTextLinks('Thanks for using Gmail.'), [
        (text: 'Thanks for using Gmail.', kind: TextSegmentKind.text),
      ]);
    });

    test('is empty for empty text', () {
      expect(splitTextLinks(''), isEmpty);
    });

    test('finds a URL alone on its line', () {
      const url = 'https://example.com/confirm/vf-%5Babc123%5D-xyz_789';
      expect(splitTextLinks('confirm:\r\n\r\n$url\r\n\r\nIf'), [
        (text: 'confirm:\r\n\r\n', kind: TextSegmentKind.text),
        (text: url, kind: TextSegmentKind.url),
        (text: '\r\n\r\nIf', kind: TextSegmentKind.text),
      ]);
    });

    test('leaves sentence punctuation out of the URL', () {
      expect(
        _links(
          'visit: http://support.google.com/mail/bin/answer.py?answer=184973.',
        ),
        ['http://support.google.com/mail/bin/answer.py?answer=184973'],
      );
      expect(_links('See https://a.com, or https://b.com!'), [
        'https://a.com',
        'https://b.com',
      ]);
    });

    test('keeps a parenthesis the URL opened', () {
      expect(_links('https://en.wikipedia.org/wiki/Mail_(protocol)'), [
        'https://en.wikipedia.org/wiki/Mail_(protocol)',
      ]);
    });

    test('drops a parenthesis the sentence opened', () {
      expect(_links('(see https://a.com/x)'), ['https://a.com/x']);
    });

    test('stops at angle brackets', () {
      expect(_links('<https://a.com/x>'), ['https://a.com/x']);
    });

    test('ignores a scheme with no host', () {
      expect(_links('https://. and http://'), isEmpty);
    });

    test('finds email addresses, leaving the final period out', () {
      expect(
        splitTextLinks(
          'alice@example.com has requested to forward mail to\r\n'
          'npub1abc@example.org.',
        ),
        [
          (text: 'alice@example.com', kind: TextSegmentKind.email),
          (
            text: ' has requested to forward mail to\r\n',
            kind: TextSegmentKind.text,
          ),
          (text: 'npub1abc@example.org', kind: TextSegmentKind.email),
          (text: '.', kind: TextSegmentKind.text),
        ],
      );
    });

    test('finds an address after mailto:', () {
      expect(_links('Write to mailto:first.last+tag@mail.example.org'), [
        'first.last+tag@mail.example.org',
      ]);
    });

    test('keeps an address inside a URL part of the URL', () {
      expect(splitTextLinks('https://a.com/u/me@b.com'), [
        (text: 'https://a.com/u/me@b.com', kind: TextSegmentKind.url),
      ]);
    });

    test('ignores an address with no domain dot', () {
      expect(_links('ping me@localhost or @handle'), isEmpty);
    });
  });
}
