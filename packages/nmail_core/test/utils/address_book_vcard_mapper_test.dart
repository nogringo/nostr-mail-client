import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nmail_core/utils/contact_birthday_utils.dart';
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

  test('creates vCard from a name-only contact', () {
    final text = AddressBookVCardMapper.buildVCard(
      const AddressBookContactForm(displayName: 'Name Only'),
    );

    final card = parser.parseSingle(text);
    expect(card.formattedName, 'Name Only');
    expect(card.emails, isEmpty);
    expect(card.telephones, isEmpty);
    expect(card.impps, isEmpty);
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

  test('creates vCard with birthday and phone', () {
    final text = AddressBookVCardMapper.buildVCard(
      const AddressBookContactForm(
        displayName: 'Phone Friend',
        phones: ['+33 6 12 34 56 78'],
        birthday: ContactBirthday(year: 1990, month: 4, day: 12),
      ),
    );

    final card = parser.parseSingle(text);
    expect(card.formattedName, 'Phone Friend');
    expect(card.telephones.single.number, '+33612345678');
    expect(card.birthday?.toDateString(), '19900412');
    expect(text, contains('TEL'));
    expect(text, contains('BDAY:19900412'));
  });

  test('creates vCard with year-less birthday', () {
    final text = AddressBookVCardMapper.buildVCard(
      const AddressBookContactForm(
        displayName: 'No Year Friend',
        emails: ['noyear@example.com'],
        birthday: ContactBirthday(month: 4, day: 12),
      ),
    );

    final card = parser.parseSingle(text);
    expect(card.birthday?.year, isNull);
    expect(card.birthday?.toDateString(), '--0412');
    expect(text, contains('BDAY:--0412'));
  });

  test('parses year-less birthday from vCard', () {
    const text = '''
BEGIN:VCARD
VERSION:4.0
UID:urn:uuid:carol
FN:Carol
EMAIL:carol@example.com
BDAY:--0412
END:VCARD
''';

    final forms = AddressBookVCardMapper.formsFromVCardText(text);
    expect(forms.single.birthday, const ContactBirthday(month: 4, day: 12));
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

  test('formsFromVCardText parses multiple vCards', () {
    const text = '''
BEGIN:VCARD
VERSION:4.0
UID:urn:uuid:alice
FN:Alice
EMAIL:alice@example.com
TEL:+33611111111
END:VCARD
BEGIN:VCARD
VERSION:4.0
UID:urn:uuid:bob
FN:Bob
EMAIL:bob@example.com
BDAY:19900412
END:VCARD
''';

    final forms = AddressBookVCardMapper.formsFromVCardText(text);
    expect(forms.length, 2);
    expect(forms[0].uid, 'urn:uuid:alice');
    expect(forms[0].displayName, 'Alice');
    expect(forms[0].emails, ['alice@example.com']);
    expect(forms[0].phones, ['+33611111111']);
    expect(forms[1].uid, 'urn:uuid:bob');
    expect(forms[1].emails, ['bob@example.com']);
    expect(
      forms[1].birthday,
      const ContactBirthday(year: 1990, month: 4, day: 12),
    );
  });

  test('mergeForms unions emails, phones and keeps existing birthday', () {
    const base = AddressBookContactForm(
      uid: 'urn:uuid:alice',
      displayName: 'Alice',
      emails: ['alice@example.com'],
      phones: ['+33611111111'],
      birthday: ContactBirthday(year: 1990, month: 4, day: 12),
    );
    const incoming = AddressBookContactForm(
      displayName: 'Alice Example',
      emails: ['ALICE@example.com', 'alice@work.com'],
      phones: ['+33622222222'],
      birthday: ContactBirthday(year: 2000, month: 1, day: 1),
    );

    final merged = AddressBookVCardMapper.mergeForms(base, incoming);
    expect(merged.uid, 'urn:uuid:alice');
    expect(merged.displayName, 'Alice');
    // Case-insensitive dedup keeps the first occurrence and adds the new one.
    expect(merged.emails, ['alice@example.com', 'alice@work.com']);
    expect(merged.phones, ['+33611111111', '+33622222222']);
    expect(
      merged.birthday,
      const ContactBirthday(year: 1990, month: 4, day: 12),
    );
  });

  test('creates vCard with company, job title and notes', () {
    final text = AddressBookVCardMapper.buildVCard(
      const AddressBookContactForm(
        displayName: 'Work Friend',
        organization: ' Acme ',
        jobTitle: 'Engineer',
        note: 'Met at FOSDEM\nLikes tea',
      ),
    );

    final card = parser.parseSingle(text);
    expect(card.organization?.toFormattedString(), 'Acme');
    expect(card.title, 'Engineer');
    expect(card.note, 'Met at FOSDEM\nLikes tea');
  });

  test('parses company, job title and notes from vCard', () {
    const text = '''
BEGIN:VCARD
VERSION:4.0
FN:Dana
ORG:Acme;R&D
TITLE:Engineer
NOTE:Met at FOSDEM
END:VCARD
''';

    final form = AddressBookVCardMapper.formsFromVCardText(text).single;
    expect(form.organization, 'Acme, R&D');
    expect(form.jobTitle, 'Engineer');
    expect(form.note, 'Met at FOSDEM');
  });

  test('editing keeps an unchanged company and drops cleared fields', () {
    const existing = '''
BEGIN:VCARD
VERSION:4.0
UID:urn:uuid:dana
FN:Dana
ORG:Acme;R&D
TITLE:Engineer
NOTE:Met at FOSDEM
END:VCARD
''';

    final unchanged = parser.parseSingle(
      AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(
          displayName: 'Dana',
          organization: 'Acme, R&D',
        ),
        existingVCard: existing,
      ),
    );
    expect(unchanged.organization?.name, 'Acme');
    expect(unchanged.organization?.units, ['R&D']);
    expect(unchanged.title, isNull);
    expect(unchanged.note, isNull);

    final renamed = parser.parseSingle(
      AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(
          displayName: 'Dana',
          organization: 'Globex',
        ),
        existingVCard: existing,
      ),
    );
    expect(renamed.organization?.toFormattedString(), 'Globex');
  });

  test('mergeForms keeps existing company and appends new notes', () {
    const base = AddressBookContactForm(
      displayName: 'Alice',
      organization: 'Acme',
      note: 'Met at FOSDEM',
    );

    final merged = AddressBookVCardMapper.mergeForms(
      base,
      const AddressBookContactForm(
        displayName: 'Alice',
        organization: 'Globex',
        jobTitle: 'Engineer',
        note: 'Likes tea',
      ),
    );
    expect(merged.organization, 'Acme');
    expect(merged.jobTitle, 'Engineer');
    expect(merged.note, 'Met at FOSDEM\n\nLikes tea');

    final reimported = AddressBookVCardMapper.mergeForms(
      merged,
      const AddressBookContactForm(displayName: 'Alice', note: 'Likes tea'),
    );
    expect(reimported.note, merged.note);
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
    expect(
      () => AddressBookVCardMapper.buildVCard(
        const AddressBookContactForm(
          displayName: 'Bad Phone',
          phones: ['not-a-phone'],
        ),
      ),
      throwsA(isA<AddressBookValidationException>()),
    );
  });
}
