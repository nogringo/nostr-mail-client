import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail_client/models/address_book_contact_form.dart';
import 'package:nostr_mail_client/utils/address_book_vcard_mapper.dart';
import 'package:vcard_dart/vcard_dart.dart';

void main() {
  final parser = VCardParser();

  test('creates minimal vCard with name and email', () {
    final text = AddressBookVCardMapper.buildVCard(
      const AddressBookContactForm(
        displayName: 'Alice Example',
        emails: ['alice@example.com'],
      ),
    );

    final card = parser.parseSingle(text);
    expect(card.version, VCardVersion.v40);
    expect(card.formattedName, 'Alice Example');
    expect(card.emails.single.address, 'alice@example.com');
  });

  test('creates vCard with Nostr npub IMPP', () {
    const factory = Bip340EventSignerFactory();
    final (_, pubkey) = factory.generateKeyPair();

    final text = AddressBookVCardMapper.buildVCard(
      AddressBookContactForm(
        displayName: 'Nostr Friend',
        nostrPubkeys: [Nip19.encodePubKey(pubkey)],
      ),
    );

    final card = parser.parseSingle(text);
    expect(card.formattedName, 'Nostr Friend');
    expect(card.impps.single.uri, 'nostr:${Nip19.encodePubKey(pubkey)}');
  });

  test('editing preserves UID and X properties', () {
    const existing = '''
BEGIN:VCARD
VERSION:4.0
UID:urn:uuid:test-contact
FN:Old Name
EMAIL:old@example.com
X-NMAIL-CUSTOM:keep-me
END:VCARD
''';

    final text = AddressBookVCardMapper.buildVCard(
      const AddressBookContactForm(
        displayName: 'New Name',
        emails: ['new@example.com'],
      ),
      existingVCard: existing,
    );

    final card = parser.parseSingle(text);
    expect(card.uid, 'urn:uuid:test-contact');
    expect(card.formattedName, 'New Name');
    expect(card.emails.single.address, 'new@example.com');
    expect(text, contains('X-NMAIL-CUSTOM:keep-me'));
  });

  test('rejects invalid forms', () {
    expect(
      () => AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(displayName: '', emails: ['a@b.com']),
      ),
      throwsA(isA<AddressBookValidationException>()),
    );
    expect(
      () => AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(displayName: 'No Method'),
      ),
      throwsA(isA<AddressBookValidationException>()),
    );
    expect(
      () => AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(
          displayName: 'Bad Mail',
          emails: ['not-an-email'],
        ),
      ),
      throwsA(isA<AddressBookValidationException>()),
    );
    expect(
      () => AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(
          displayName: 'Bad Nostr',
          nostrPubkeys: ['not-a-pubkey'],
        ),
      ),
      throwsA(isA<AddressBookValidationException>()),
    );
  });
}
