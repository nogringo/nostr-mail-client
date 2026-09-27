import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/reply_quote.dart';
import 'package:nostr_mail/nostr_mail.dart' show Email;

Email _email(MimeMessage mime) => Email(
  id: 'id',
  senderPubkey: 'sender',
  recipientPubkey: 'recipient',
  lightMimeText: '',
  attachmentRefs: const [],
  createdAt: DateTime(2026),
  isBridged: false,
  mimeMessage: mime,
);

Email _htmlEmail(String html, {String text = ''}) => _email(
  (MessageBuilder.prepareMultipartAlternativeMessage()
        ..addTextPlain(text)
        ..addTextHtml(html))
      .buildMimeMessage(),
);

void main() {
  test('normalizeLineBreaks turns CRLF and CR into LF', () {
    expect(normalizeLineBreaks('a\r\nb\rc\nd'), 'a\nb\nc\nd');
  });

  group('quoteHtml', () {
    test('puts the escaped header above the body', () {
      final html = quoteHtml(
        _htmlEmail('<p>Hello</p>'),
        header: ['From: Alice <alice@example.com>'],
      );

      expect(html, contains('From: Alice &lt;alice@example.com&gt;'));
      expect(html.indexOf('From:'), lessThan(html.indexOf('<p>Hello</p>')));
    });

    test('quotes the HTML part over a Markdown text/plain part', () {
      final html = quoteHtml(
        _htmlEmail('<p>Sent with Nmail</p>', text: 'Sent with **Nmail**'),
        header: const [],
      );

      expect(html, contains('<p>Sent with Nmail</p>'));
      expect(html, isNot(contains('**')));
    });

    test('keeps the line breaks of a plain text body', () {
      final message = MessageBuilder()..text = 'one\r\ntwo <3';

      expect(
        quoteHtml(_email(message.buildMimeMessage()), header: const []),
        contains('one<br>two &lt;3'),
      );
    });

    test('sets the body of a reply off in a blockquote', () {
      final html = quoteHtml(
        _htmlEmail('<p>Hello</p>'),
        header: const ['On x, y wrote:'],
        asReply: true,
      );

      expect(
        html,
        matches(
          RegExp(r'wrote:</div><blockquote[^>]*><p>Hello</p></blockquote>'),
        ),
      );
    });
  });

  group('splitQuote', () {
    test('takes apart what appendQuote joined', () {
      final quote = quoteHtml(
        _htmlEmail('<p>Hello</p>'),
        header: const ['Forwarded'],
      );

      final split = splitQuote(appendQuote('<p>FYI</p>', quote));

      expect(split.body, '<p>FYI</p>');
      expect(split.quote, contains('<p>Hello</p>'));
      expect(split.quoteIsReply, isFalse);
    });

    test('tells the quote of a reply apart', () {
      final quote = quoteHtml(
        _htmlEmail('<p>Hello</p>'),
        header: const ['On x, y wrote:'],
        asReply: true,
      );

      expect(
        splitQuote(appendQuote('<p>Thanks</p>', quote)).quoteIsReply,
        isTrue,
      );
    });

    test('leaves HTML without a quote as it is', () {
      const html = '<p>Hi</p><br><blockquote>older quote</blockquote>';

      final split = splitQuote(html);

      expect(split.body, html);
      expect(split.quote, isNull);
    });
  });
}
