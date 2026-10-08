import 'package:flutter/material.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../shared/layout_constants.dart';
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

  static const _avatarRadius = 18.0;
  static const _avatarInset = 10.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final email = contact.index.emails.isEmpty
        ? ''
        : contact.index.emails.first;
    final label = contact.index.formattedName.isEmpty
        ? email
        : contact.index.formattedName;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.navigationInset,
        vertical: 2,
      ),
      child: ListTile(
        selected: selected,
        selectedTileColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.onSecondaryContainer,
        shape: const StadiumBorder(),
        minTileHeight: 2 * (_avatarRadius + _avatarInset),
        // Below the default 8, so name and email (44 px) fit in 56.
        minVerticalPadding: 6,
        contentPadding: const EdgeInsetsDirectional.only(
          start: _avatarInset,
          end: 24,
        ),
        leading: ContactAvatar(contact: contact, radius: _avatarRadius),
        title: Text(label, overflow: TextOverflow.ellipsis),
        subtitle: email.isEmpty
            ? null
            : Text(email, overflow: TextOverflow.ellipsis),
        onTap: onTap,
      ),
    );
  }
}
