import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/views/contacts/widgets/contact_avatar.dart';
import 'package:nmail_core/views/email/widgets/person_avatar.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

void main() {
  late AddressBookService addressBook;

  setUp(() {
    addressBook = GetIt.I.registerSingleton(AddressBookService());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('a sender wears their contact avatar once saved', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PersonAvatar(
          person: EmailPerson.email(
            MailAddress('Paul Martin', 'paul@example.com'),
          ),
        ),
      ),
    );
    expect(find.byType(ContactAvatar), findsNothing);
    expect(find.text('P'), findsOneWidget);

    addressBook.contacts.value = [
      const AddressBookContact(
        uid: 'paul',
        vCard: '',
        index: ContactIndex(
          formattedName: 'Tonton',
          emails: ['paul@example.com'],
        ),
        eventId: '',
        eventCreatedAt: 0,
        pubKey: '',
      ),
    ];
    await tester.pump();

    expect(find.byType(ContactAvatar), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
  });
}
