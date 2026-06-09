import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'contact_action_row.dart';
import 'contact_header.dart';
import 'contact_nostr_section.dart';
import 'contact_section_title.dart';

class ContactDetailPane extends StatelessWidget {
  final String? uid;
  final VoidCallback? onDeleted;

  const ContactDetailPane({super.key, this.uid, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactsController>();
    final l = AppLocalizations.of(context);
    return Obx(() {
      final displayedContact = uid == null
          ? controller.selectedContact
          : controller.addressBookService.contacts.firstWhereOrNull(
              (contact) => contact.uid == uid,
            );
      if (displayedContact == null) {
        return Center(child: Text(l.contactsSelectPrompt));
      }
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ContactHeader(contact: displayedContact),
          const SizedBox(height: 24),
          if (displayedContact.index.emails.isNotEmpty) ...[
            ContactSectionTitle(l.contactsEmailsTitle),
            const SizedBox(height: 8),
            for (final email in displayedContact.index.emails)
              ContactActionRow(
                icon: Icons.alternate_email,
                title: Text(email, overflow: TextOverflow.ellipsis),
                copyValue: email,
                onCompose: () => controller.composeToEmail(context, email),
              ),
            const SizedBox(height: 24),
          ],
          ContactNostrSection(contact: displayedContact),
        ],
      );
    });
  }
}
