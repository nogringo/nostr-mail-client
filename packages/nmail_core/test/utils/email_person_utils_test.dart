import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

final _pubkey = 'a' * 64;

AddressBookContact _contact(
  String name, {
  List<String> emails = const [],
  List<String> nostrIdentifiers = const [],
}) => AddressBookContact(
  uid: name,
  vCard: '',
  index: ContactIndex(
    formattedName: name,
    emails: emails,
    nostrIdentifiers: nostrIdentifiers,
  ),
  eventId: '',
  eventCreatedAt: 0,
  pubKey: '',
);

void main() {
  late AddressBookService addressBook;

  setUp(() {
    addressBook = GetIt.I.registerSingleton(AddressBookService());
  });

  tearDown(() => GetIt.I.reset());

  test('a sender in the address book shows under the contact name', () {
    addressBook.contacts.value = [
      _contact('Paulo', emails: ['Paul@Example.com']),
    ];

    expect(
      emailPersonName(
        EmailPerson.email(MailAddress('Paul Martin', 'paul@example.com')),
      ),
      'Paulo',
    );
  });

  test('a Nostr identity is matched to its contact by public key', () {
    addressBook.contacts.value = [
      _contact(
        'Paulo',
        nostrIdentifiers: ['nostr:${Nip19.encodePubKey(_pubkey)}'],
      ),
    ];

    expect(emailPersonName(EmailPerson.nostr(_pubkey)), 'Paulo');
  });

  test('a contact with a blank name falls back to the From header name', () {
    addressBook.contacts.value = [
      _contact('  ', emails: ['paul@example.com']),
    ];

    expect(
      emailPersonName(
        EmailPerson.email(MailAddress('Paul Martin', 'paul@example.com')),
      ),
      'Paul Martin',
    );
  });
}
