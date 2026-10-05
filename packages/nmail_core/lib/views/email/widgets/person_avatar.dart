import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/views/contacts/widgets/contact_avatar.dart';
import 'package:nmail_core/widgets/email_avatar.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

class PersonAvatar extends StatelessWidget {
  final EmailPerson person;
  final double radius;

  const PersonAvatar({super.key, required this.person, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GetIt.I<AddressBookService>().contacts,
      builder: (context, contacts, _) {
        final contact = findEmailPersonContact(contacts, person);
        if (contact != null) {
          return ContactAvatar(contact: contact, radius: radius);
        }
        final pubkey = person.pubkey;
        if (pubkey != null) return NostrAvatar(pubkey: pubkey, radius: radius);
        return EmailAvatar(mailAddress: person.address!, radius: radius);
      },
    );
  }
}
