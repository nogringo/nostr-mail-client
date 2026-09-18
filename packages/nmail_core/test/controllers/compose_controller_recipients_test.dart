import 'dart:convert';

import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart' show Email;
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';

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
      Get.put<Ndk>(ndk);
      Get.put(StorageService());
      Get.put(NostrMailService());
      Get.put(ContactsService());
      controller = ComposeController();
    });

    tearDown(() async {
      Get.reset();
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
  });
}
