import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_quill/flutter_quill.dart' show BlockEmbed, Document;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart'
    show AttachmentRef, Email, NostrMailClient;
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/models/from_option.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/utils/inline_image_source.dart';

import '../helpers/fake_metadata_service.dart';

/// Serves attachment bytes from [blobs], keyed by sha256.
class _FakeMailClient implements NostrMailClient {
  final blobs = <String, Uint8List>{};

  @override
  Future<Uint8List?> getAttachmentBytes(Email email, AttachmentRef ref) async =>
      blobs[ref.sha256];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNostrMailService extends NostrMailService {
  _FakeNostrMailService(this._client);

  final NostrMailClient _client;

  @override
  NostrMailClient get client => _client;
}

final _logo = Uint8List.fromList([1, 2, 3]);
final _photo = Uint8List.fromList([4, 5, 6]);
final _pdf = Uint8List.fromList([7, 8, 9]);

/// As stored after sync: the photo and the PDF went to the blob cache, the
/// logo has no filename so it kept its bytes.
Email _quotedEmail() => Email(
  id: 'forwarded',
  senderPubkey: _pubkey,
  recipientPubkey: '',
  lightMimeText: [
    'From: =?utf-8?Q?Andr=C3=A9?= <andre@example.com>',
    'To: me@uid.ovh',
    'Subject: Photos',
    'MIME-Version: 1.0',
    'Content-Type: multipart/mixed; boundary="mixed"',
    '',
    '--mixed',
    'Content-Type: multipart/related; boundary="related"',
    '',
    '--related',
    'Content-Type: text/html; charset=utf-8',
    '',
    '<p><img src="cid:Logo@X"></p><p><img src="cid:photo@x"></p>',
    '--related',
    'Content-Type: image/png',
    'Content-ID: <Logo@X>',
    'Content-Transfer-Encoding: base64',
    '',
    base64Encode(_logo),
    '--related',
    'Content-Type: image/png; name="photo.png"',
    'Content-Disposition: inline; filename="photo.png"',
    'Content-ID: <photo@x>',
    '',
    '',
    '--related--',
    '--mixed',
    'Content-Type: application/pdf; name="doc.pdf"',
    'Content-Disposition: attachment; filename="doc.pdf"',
    '',
    '',
    '--mixed--',
  ].join('\r\n'),
  attachmentRefs: const [
    AttachmentRef(
      filename: 'photo.png',
      contentType: 'image/png',
      size: 3,
      sha256: 'photo',
      contentId: 'photo@x',
    ),
    AttachmentRef(
      filename: 'doc.pdf',
      contentType: 'application/pdf',
      size: 3,
      sha256: 'pdf',
    ),
  ],
  createdAt: DateTime(2026, 9, 27),
  isBridged: true,
);

const _pubkey =
    '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d';

const _otherPubkey =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';

/// Every NIP-05 lookup finds a key, so an SMTP address that gets promoted
/// behind the scenes would show up as a Nostr recipient.
final _nip05Everywhere = MockClient((request) async {
  final name = request.url.queryParameters['name']!;
  return http.Response(
    jsonEncode({
      'names': {name: _otherPubkey},
    }),
    200,
  );
});

Email _email({required String from, String cc = '', required bool isBridged}) =>
    Email(
      id: 'id',
      senderPubkey: _pubkey,
      recipientPubkey: '',
      lightMimeText:
          'From: $from\r\nTo: me@uid.ovh\r\n'
          '${cc.isEmpty ? '' : 'Cc: $cc\r\n'}'
          'Subject: Hi\r\n\r\nHello',
      attachmentRefs: const [],
      createdAt: DateTime(2026, 9, 18),
      isBridged: isBridged,
    );

Recipient _smtp(String email) => Recipient(
  input: email,
  mailAddress: MailAddress(null, email),
  type: RecipientType.legacy,
);

Recipient _promoted(String email) => Recipient(
  input: email,
  pubkey: _pubkey,
  mailAddress: MailAddress(null, email),
  type: RecipientType.nostr,
);

void main() {
  group('Recipient.smtpAddress', () {
    test('is the input of an SMTP recipient', () {
      expect(_smtp('support@opensats.org').smtpAddress, 'support@opensats.org');
    });

    test('is kept on a recipient promoted to Nostr through NIP-05', () {
      expect(
        _promoted('support@opensats.org').smtpAddress,
        'support@opensats.org',
      );
    });

    test('is null for a recipient entered as a key', () {
      final npub = Nip19.encodePubKey(_pubkey);
      expect(
        Recipient(
          input: npub,
          pubkey: _pubkey,
          type: RecipientType.nostr,
        ).smtpAddress,
        isNull,
      );
    });

    test('ignores an npub address, which leads back to the same key', () {
      final npub = Nip19.encodePubKey(_pubkey);
      expect(
        Recipient(
          input: '$npub@uid.ovh',
          pubkey: _pubkey,
          mailAddress: MailAddress(null, '$npub@uid.ovh'),
          type: RecipientType.nostr,
        ).smtpAddress,
        isNull,
      );
    });
  });

  group('ComposeController recipient actions', () {
    late Ndk ndk;
    late FakeMetadataService metadataService;
    late _FakeMailClient mailClient;
    late ComposeController controller;

    setUp(() {
      Get.testMode = true;
      ndk = Ndk(
        NdkConfig(
          cache: MemCacheManager(),
          eventVerifier: Bip340EventVerifier(useIsolate: false),
          bootstrapRelays: const [],
          logLevel: LogLevel.off,
        ),
      );
      GetIt.I.registerSingleton<Ndk>(ndk);
      Get.put(StorageService());
      mailClient = _FakeMailClient();
      Get.put<NostrMailService>(_FakeNostrMailService(mailClient));
      metadataService = FakeMetadataService();
      Get.put<MetadataService>(metadataService);
      Get.put(ContactsService());
      controller = ComposeController();
    });

    tearDown(() async {
      Get.reset();
      await GetIt.I.reset();
      await ndk.destroy();
    });

    test('sendViaSmtp turns a promoted recipient back into SMTP in place', () {
      final other = _smtp('bob@example.com');
      final promoted = _promoted('support@opensats.org');
      controller.recipients.addAll([promoted, other]);

      controller.sendViaSmtp(
        RecipientField.to,
        promoted,
        'support@opensats.org',
      );

      final switched = controller.recipients.first;
      expect(switched.isLegacy, isTrue);
      expect(switched.input, 'support@opensats.org');
      expect(switched.pubkey, isNull);
      expect(controller.recipients.last, same(other));
    });

    test('sendViaSmtp switches a key-only recipient to its NIP-05', () {
      final keyOnly = Recipient(
        input: Nip19.encodePubKey(_pubkey),
        pubkey: _pubkey,
        type: RecipientType.nostr,
      );
      controller.recipients.add(keyOnly);

      controller.sendViaSmtp(RecipientField.to, keyOnly, 'hello@opensats.org');

      final switched = controller.recipients.single;
      expect(switched.isLegacy, isTrue);
      expect(switched.smtpAddress, 'hello@opensats.org');
    });

    test('moveRecipient moves a recipient to Cc and shows the Cc field', () {
      final recipient = _smtp('bob@example.com');
      controller.recipients.add(recipient);

      controller.moveRecipient(recipient, RecipientField.to, RecipientField.cc);

      expect(controller.recipients, isEmpty);
      expect(controller.ccRecipients.single, same(recipient));
      expect(controller.showExpandedFields.value, isTrue);
    });

    test('moveRecipient does not duplicate a recipient already there', () {
      controller.recipients.add(_smtp('bob@example.com'));
      controller.bccRecipients.add(_smtp('Bob@Example.com'));

      controller.moveRecipient(
        controller.recipients.first,
        RecipientField.to,
        RecipientField.bcc,
      );

      expect(controller.recipients, isEmpty);
      expect(controller.bccRecipients, hasLength(1));
    });

    test('removeRecipientFrom removes the given chip only', () {
      final keep = _smtp('alice@example.com');
      final remove = _smtp('bob@example.com');
      controller.ccRecipients.addAll([keep, remove]);

      controller.removeRecipientFrom(RecipientField.cc, remove);

      expect(controller.ccRecipients.single, same(keep));
    });

    group('addReplyRecipients', () {
      Future<void> reply(Email email, {List<String> cc = const []}) =>
          http.runWithClient(() async {
            controller.addReplyRecipients(
              email,
              to: [email.sender!],
              cc: [for (final address in cc) MailAddress(null, address)],
            );
            await pumpEventQueue();
          }, () => _nip05Everywhere);

      test('keeps the sender of an email that came through SMTP', () async {
        await reply(_email(from: 'support@opensats.org', isBridged: true));

        final recipient = controller.recipients.single;
        expect(recipient.isLegacy, isTrue);
        expect(recipient.input, 'support@opensats.org');
      });

      test('sends to the pubkey of an email that came through Nostr', () async {
        await reply(_email(from: 'alice@alice.com', isBridged: false));

        final recipient = controller.recipients.single;
        expect(recipient.isNostr, isTrue);
        expect(recipient.pubkey, _pubkey);
        expect(recipient.smtpAddress, 'alice@alice.com');
      });

      test('keeps the SMTP recipients of a Nostr email', () async {
        await reply(
          _email(from: 'alice@alice.com', isBridged: false),
          cc: ['bob@example.com'],
        );

        final recipient = controller.ccRecipients.single;
        expect(recipient.isLegacy, isTrue);
        expect(recipient.input, 'bob@example.com');
      });

      test('an npub address stays a Nostr recipient', () async {
        final npub = Nip19.encodePubKey(_otherPubkey);
        await reply(
          _email(from: 'support@opensats.org', isBridged: true),
          cc: ['$npub@nostr'],
        );

        final recipient = controller.ccRecipients.single;
        expect(recipient.isNostr, isTrue);
        expect(recipient.pubkey, _otherPubkey);
      });
    });

    group('applyReplyFrom', () {
      final npub = Nip19.encodePubKey(_pubkey);
      FromOption option(String address, FromSource source) =>
          FromOption(mailAddress: MailAddress(null, address), source: source);

      test('replies from the identity the email reached', () {
        final bridge = option('$npub@uid.ovh', FromSource.npubBridge);
        final identity = option('me@uid.ovh', FromSource.customIdentity);
        controller.fromOptions.addAll([bridge, identity]);
        controller.selectedFrom.value = bridge;

        controller.applyReplyFrom(
          _email(from: 'support@opensats.org', isBridged: true),
        );

        expect(controller.selectedFrom.value, same(identity));
      });

      test('waits for the From options to load', () async {
        controller.applyReplyFrom(
          _email(from: 'support@opensats.org', isBridged: true),
        );
        final identity = option('me@uid.ovh', FromSource.customIdentity);
        controller.fromOptions.value = [
          option('$npub@nostr', FromSource.npubNostr),
          identity,
        ];
        await pumpEventQueue();

        expect(controller.selectedFrom.value, same(identity));
      });

      test('replies to an own email from its From', () {
        final work = option('me@work.com', FromSource.customIdentity);
        controller.fromOptions.addAll([
          option('me@uid.ovh', FromSource.customIdentity),
          work,
        ]);

        controller.applyReplyFrom(
          _email(from: 'me@work.com', isBridged: false),
        );

        expect(controller.selectedFrom.value, same(work));
      });

      test('keeps the bridge of a legacy recipient over npub@nostr', () {
        final bridge = option('$npub@uid.ovh', FromSource.npubBridge);
        controller.fromOptions.addAll([
          option('$npub@nostr', FromSource.npubNostr),
          bridge,
        ]);
        controller.selectedFrom.value = bridge;

        controller.applyReplyFrom(
          _email(from: 'alice@alice.com', cc: '$npub@nostr', isBridged: false),
        );

        expect(controller.selectedFrom.value, same(bridge));
      });
    });

    group('buildMimeMessage', () {
      test('names a Nostr recipient after their profile', () {
        metadataService.resolve(Metadata(pubKey: _pubkey, name: 'Alice'));
        controller.recipients.add(
          Contact(
            pubkey: _pubkey,
            displayName: 'Grumpy neighbour',
            source: ContactSource.addressBook,
          ).toRecipient(),
        );

        final mime = controller.buildMimeMessage(
          subject: 'Hi',
          document: Document(),
        );

        expect(mime.to!.single.personalName, 'Alice');
      });

      test('leaves the names given to contacts out of the email', () {
        controller.recipients.add(
          Contact(
            pubkey: _pubkey,
            displayName: 'Grumpy neighbour',
            source: ContactSource.addressBook,
          ).toRecipient(),
        );
        controller.ccRecipients.add(
          Contact(
            displayName: 'Tax man',
            mailAddress: MailAddress('Tax man', 'bob@example.com'),
            source: ContactSource.addressBook,
          ).toRecipient(),
        );

        final email = controller
            .buildMimeMessage(subject: 'Hi', document: Document())
            .renderMessage();

        expect(email, isNot(contains('Grumpy neighbour')));
        expect(email, isNot(contains('Tax man')));
      });

      test('sends a pasted image inline, next to the HTML body', () async {
        final png = File('test/fixtures/media_metadata/photo.png');
        final url = await controller.addInlineImage(await png.readAsBytes());
        final document = Document()
          ..insert(0, 'Look:\n')
          ..insert(6, BlockEmbed.image(url));

        final mime = controller.buildMimeMessage(
          subject: 'Hi',
          document: document,
        );

        final contentId = contentIdFromUrl(url)!;
        final related = mime.allPartsFlat.singleWhere(
          (part) => part.mediaType.sub == MediaSubtype.multipartRelated,
        );
        final image = related.parts!.singleWhere(
          (part) => part.mediaType.isImage,
        );
        expect(
          normalizeContentId(image.getHeaderValue('content-id')),
          contentId,
        );
        expect(
          image.getHeaderContentDisposition()?.disposition,
          ContentDisposition.inline,
        );
        expect(mime.decodeTextHtmlPart(), contains('src="$url"'));
        expect(mime.findContentInfo(), isEmpty);
      });

      test('leaves out an image deleted from the body', () async {
        final png = File('test/fixtures/media_metadata/photo.png');
        await controller.addInlineImage(await png.readAsBytes());

        final mime = controller.buildMimeMessage(
          subject: 'Hi',
          document: Document()..insert(0, 'No image'),
        );

        expect(
          mime.allPartsFlat.where((part) => part.mediaType.isImage),
          isEmpty,
        );
      });
    });

    group('quote', () {
      setUp(() => mailClient.blobs.addAll({'photo': _photo, 'pdf': _pdf}));

      MimeMessage send(String body) => MimeMessage.parseFromText(
        controller
            .buildMimeMessage(
              subject: 'Photos',
              document: Document()..insert(0, body),
            )
            .renderMessage(),
      );

      test(
        'a forward loads the images it shows, then the attachments',
        () async {
          await controller.quoteForward(_quotedEmail());

          expect(await controller.inlineImageBytes('logo@x'), _logo);
          expect(await controller.inlineImageBytes('photo@x'), _photo);
          final attachment = controller.attachments.single;
          expect(attachment.filename, 'doc.pdf');
          expect(attachment.mimeType, 'application/pdf');
          expect(attachment.data, _pdf);
        },
      );

      test(
        'a forward sends the quote below the body, with its images',
        () async {
          await controller.quoteForward(_quotedEmail());

          final sent = send('FYI');

          final html = sent.decodeTextHtmlPart()!;
          expect(
            html.indexOf('FYI'),
            lessThan(html.indexOf('Forwarded message')),
          );
          expect(html, contains('From: André &lt;andre@example.com&gt;'));
          expect(html, contains('To: me@uid.ovh'));
          expect(sent.decodeTextPlainPart(), contains('Forwarded message'));
          for (final (contentId, bytes) in [
            ('logo@x', _logo),
            ('photo@x', _photo),
          ]) {
            expect(html, contains('src="cid:$contentId"'));
            final image = sent.allPartsFlat.singleWhere(
              (part) => part.getHeaderValue('content-id') == '<$contentId>',
            );
            expect(image.decodeContentBinary(), bytes);
          }
          expect(sent.findContentInfo().single.fileName, 'doc.pdf');
        },
      );

      test('a reply sends the images it quotes, not the attachments', () async {
        await controller.quoteReply(_quotedEmail());

        final sent = send('Thanks');

        final html = sent.decodeTextHtmlPart()!;
        expect(html, contains('André &lt;andre@example.com&gt; wrote:'));
        expect(html, contains('<blockquote'));
        expect(
          sent.allPartsFlat.where(
            (part) => part.getHeaderValue('content-id') == '<photo@x>',
          ),
          hasLength(1),
        );
        expect(controller.attachments, isEmpty);
        expect(sent.findContentInfo(), isEmpty);
      });

      test('a reply quote starts folded and can be left out', () async {
        await controller.quoteReply(_quotedEmail());
        expect(controller.quoteIsReply, isTrue);
        expect(controller.quoteExpanded.value, isFalse);

        controller.removeQuote();
        final sent = send('Thanks');

        expect(controller.quotedEmailHtml.value, isNull);
        expect(sent.decodeTextHtmlPart(), isNot(contains('wrote:')));
        expect(
          sent.allPartsFlat.where(
            (part) => part.getHeaderValue('content-id') != null,
          ),
          isEmpty,
        );
      });

      test('a forward quote cannot be folded away', () async {
        await controller.quoteForward(_quotedEmail());

        expect(controller.quoteIsReply, isFalse);
      });
    });
  });
}
