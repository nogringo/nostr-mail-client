import 'package:flutter/material.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'contact_avatar.dart';

class ContactHeader extends StatelessWidget {
  final AddressBookContact contact;

  const ContactHeader({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ContactAvatar(contact: contact, radius: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            contact.index.formattedName,
            style: Theme.of(context).textTheme.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
