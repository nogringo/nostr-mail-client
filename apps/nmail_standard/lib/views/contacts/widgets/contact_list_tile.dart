import 'package:flutter/material.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'contact_avatar.dart';

class ContactListTile extends StatelessWidget {
  final AddressBookContact contact;
  final bool selected;
  final VoidCallback onTap;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final email = contact.index.emails.isEmpty
        ? ''
        : contact.index.emails.first;
    final label = contact.index.formattedName.isEmpty
        ? email
        : contact.index.formattedName;
    return ListTile(
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.55),
      leading: ContactAvatar(contact: contact, radius: 18),
      title: Text(label, overflow: TextOverflow.ellipsis),
      subtitle: email.isEmpty
          ? null
          : Text(email, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
