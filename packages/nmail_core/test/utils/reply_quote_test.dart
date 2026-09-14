import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/reply_quote.dart';

void main() {
  test('normalizeLineBreaks turns CRLF and CR into LF', () {
    expect(normalizeLineBreaks('a\r\nb\rc\nd'), 'a\nb\nc\nd');
  });

  group('replyQuoteDelta', () {
    Document build(String body) => Document.fromDelta(
      replyQuoteDelta(header: 'On x, y wrote:\n', body: body),
    );

    test('keeps no carriage return from a CRLF body', () {
      final doc = build('Hi, seems to be\r\ngetting rejected.\r\n\r\n');

      expect(doc.toPlainText(), isNot(contains('\r')));
    });

    test('quotes each line and drops trailing blank lines', () {
      final doc = build('first\r\n> second\r\n\r\n\r\n');

      expect(doc.toPlainText(), 'On x, y wrote:\nfirst\nsecond\n\n');
      final quoted = doc.root.children
          .expand((node) => node is Block ? node.children : [node])
          .whereType<Line>()
          .where((line) => line.style.containsKey(Attribute.blockQuote.key))
          .map((line) => line.toPlainText())
          .toList();
      expect(quoted, ['first\n', 'second\n']);
    });
  });
}
