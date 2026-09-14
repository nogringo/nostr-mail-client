import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/reply_quote.dart';
import 'package:nostr_mail/nostr_mail.dart' show Email;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

void main() {
  test('normalizeLineBreaks turns CRLF and CR into LF', () {
    expect(normalizeLineBreaks('a\r\nb\rc\nd'), 'a\nb\nc\nd');
  });

  group('quotableText', () {
    Email email(MimeMessage mime) => Email(
      id: 'id',
      senderPubkey: 'sender',
      recipientPubkey: 'recipient',
      lightMimeText: '',
      attachmentRefs: const [],
      createdAt: DateTime(2026),
      isBridged: false,
      mimeMessage: mime,
    );

    test('reads the HTML part over a Markdown text/plain part', () {
      final document = Document()
        ..insert(0, '\n\n--\nSent with Nmail\nhttps://nostrmail.org');
      final html = QuillDeltaToHtmlConverter(
        document.toDelta().toJson().cast<Map<String, dynamic>>(),
        ConverterOptions.forEmail(),
      ).convert();
      final builder = MessageBuilder.prepareMultipartAlternativeMessage()
        ..addTextPlain(
          r'\-\-'
          '\n\nSent with Nmail\n\n'
          r'[https://nostrmail\.org](https://nostrmail.org)',
        )
        ..addTextHtml(html);

      final quote = Document.fromDelta(
        replyQuoteDelta(
          header: '',
          body: quotableText(email(builder.buildMimeMessage())),
        ),
      );

      expect(
        quote.toPlainText(),
        '-- \nSent with Nmail\nhttps://nostrmail.org\n\n',
      );
    });

    test('falls back to the text/plain part', () {
      final builder = MessageBuilder()..text = 'plain body';

      expect(quotableText(email(builder.buildMimeMessage())), 'plain body');
    });
  });

  group('replyQuoteDelta', () {
    Document build(String body) => Document.fromDelta(
      replyQuoteDelta(header: 'On x, y wrote:\n', body: body),
    );

    test('keeps no carriage return from a CRLF body', () {
      final doc = build('Hi, seems to be\r\ngetting rejected.\r\n\r\n');

      expect(doc.toPlainText(), isNot(contains('\r')));
    });

    test('quotes each line and drops surrounding blank lines', () {
      final doc = build('\r\n \r\nfirst\r\n> second\r\n\r\n\r\n');

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
