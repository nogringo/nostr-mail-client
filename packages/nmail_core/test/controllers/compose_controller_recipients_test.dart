import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';

const _pubkey =
    '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d';

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
  });
}
