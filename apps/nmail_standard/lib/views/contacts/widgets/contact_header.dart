import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'contact_avatar.dart';
import 'contact_copy_feedback.dart';

class ContactHeader extends StatelessWidget {
  final AddressBookContact contact;

  const ContactHeader({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final name = contact.index.formattedName;
    return Row(
      children: [
        ContactAvatar(contact: contact, radius: 32),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _copyNameAction(context, name),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  VoidCallback? _copyNameAction(BuildContext context, String name) {
    if (name.trim().isEmpty) return null;
    return () => _copyName(context, name);
  }

  void _copyName(BuildContext context, String name) {
    Get.find<ContactsController>().copyText(name);
    showContactCopyFeedback(context, AppLocalizations.of(context).authCopied);
  }
}
