import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/inline_image_source.dart';
import 'package:nostr_mail/nostr_mail.dart';

/// A one pixel PNG, as a sender would embed one.
const _pngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

MimeMessage _relatedMessage({required String body, bool emptied = false}) =>
    MimeMessage.parseFromText(
      'From: a@b.test\r\n'
      'To: c@d.test\r\n'
      'Subject: bonjour\r\n'
      'Content-Type: multipart/related; boundary="B"\r\n'
      '\r\n'
      '--B\r\n'
      'Content-Type: text/html; charset=utf-8\r\n'
      '\r\n'
      '<p>x</p><img src="cid:logo@nmail">\r\n'
      '--B\r\n'
      'Content-Type: image/png\r\n'
      'Content-Transfer-Encoding: base64\r\n'
      'Content-ID: <Logo@Nmail>\r\n'
      '\r\n'
      '${emptied ? '' : body}\r\n'
      '--B--\r\n',
    );

void main() {
  group('isEmbeddedImageUrl', () {
    test('is true for a cid reference', () {
      expect(isEmbeddedImageUrl('cid:logo@x'), isTrue);
      expect(isEmbeddedImageUrl('CID:logo@x'), isTrue);
    });

    test('is true for a data uri', () {
      expect(isEmbeddedImageUrl('data:image/png;base64,AAA'), isTrue);
    });

    test('is false for anything fetched over the network', () {
      expect(isEmbeddedImageUrl('https://e.test/p.gif'), isFalse);
      expect(isEmbeddedImageUrl('p.gif'), isFalse);
      expect(isEmbeddedImageUrl(''), isFalse);
      expect(isEmbeddedImageUrl(null), isFalse);
    });
  });

  group('contentIdFromUrl', () {
    test('reads the content id', () {
      expect(contentIdFromUrl('cid:logo@nmail'), 'logo@nmail');
    });

    test('lowercases the scheme and the value', () {
      expect(contentIdFromUrl('CID:Logo@Nmail'), 'logo@nmail');
    });

    test('decodes percent escapes', () {
      expect(contentIdFromUrl('cid:logo%40nmail'), 'logo@nmail');
    });

    test('strips angle brackets senders sometimes keep', () {
      expect(contentIdFromUrl('cid:<logo@nmail>'), 'logo@nmail');
      expect(contentIdFromUrl('cid:%3Clogo%40nmail%3E'), 'logo@nmail');
    });

    test('survives a percent sign that is not an escape', () {
      expect(contentIdFromUrl('cid:100%@nmail'), '100%@nmail');
    });

    test('is null for an empty reference', () {
      expect(contentIdFromUrl('cid:'), isNull);
      expect(contentIdFromUrl('cid:   '), isNull);
    });

    test('is null for any other url', () {
      expect(contentIdFromUrl('https://e.test/p.gif'), isNull);
      expect(contentIdFromUrl('data:image/png;base64,AAA'), isNull);
      expect(contentIdFromUrl(null), isNull);
    });
  });

  group('normalizeContentId', () {
    test('brings both sides of a comparison to the same form', () {
      expect(normalizeContentId('<Logo@Nmail>'), 'logo@nmail');
      expect(normalizeContentId(' logo@nmail '), 'logo@nmail');
    });

    test('is null for nothing usable', () {
      expect(normalizeContentId(null), isNull);
      expect(normalizeContentId('  '), isNull);
      expect(normalizeContentId('<>'), isNull);
    });
  });

  group('inlineImageFromMime', () {
    test('decodes a part the extractor left alone', () {
      final mime = _relatedMessage(body: _pngBase64);
      final bytes = inlineImageFromMime(mime, 'logo@nmail');
      expect(bytes, isNotNull);
      expect(bytes!.sublist(1, 4), [0x50, 0x4e, 0x47]);
    });

    test('is null once the payload was extracted out to Blossom', () {
      final mime = _relatedMessage(body: _pngBase64, emptied: true);
      expect(inlineImageFromMime(mime, 'logo@nmail'), isNull);
    });

    test('is null for a content id the message does not carry', () {
      final mime = _relatedMessage(body: _pngBase64);
      expect(inlineImageFromMime(mime, 'hero@nmail'), isNull);
    });
  });

  group('inlineImageRef', () {
    const ref = AttachmentRef(
      filename: 'logo.png',
      contentType: 'image/png',
      size: 68,
      sha256: 'abc',
      contentId: 'Logo@Nmail',
    );

    test('matches whatever case the sender wrote', () {
      expect(inlineImageRef([ref], 'logo@nmail'), same(ref));
    });

    test('is null when no attachment carries the content id', () {
      expect(inlineImageRef([ref], 'hero@nmail'), isNull);
    });

    test('is null when the attachments carry no content id at all', () {
      const plain = AttachmentRef(
        filename: 'facture.pdf',
        contentType: 'application/pdf',
        size: 12,
        sha256: 'def',
      );
      expect(inlineImageRef([plain], 'logo@nmail'), isNull);
    });
  });
}
