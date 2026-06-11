import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/contact_birthday_utils.dart';
import 'contact_action_row.dart';
import 'contact_header.dart';
import 'contact_nostr_section.dart';
import 'contact_section_title.dart';
import 'phone_action_buttons.dart';

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
      final form = controller.formFor(displayedContact);
      final birthday = form.birthday;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ContactHeader(contact: displayedContact),
          const SizedBox(height: 24),
          if (birthday != null) ...[
            ContactSectionTitle(l.contactsBirthdayTitle),
            const SizedBox(height: 8),
            ContactActionRow(
              icon: Icons.cake_outlined,
              title: Text(
                formatContactBirthdayForDisplay(context, birthday),
                overflow: TextOverflow.ellipsis,
              ),
              copyValue: formatContactBirthdayForDisplay(context, birthday),
            ),
            const SizedBox(height: 24),
          ],
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
          if (form.phones.isNotEmpty) ...[
            ContactSectionTitle(l.contactsPhonesTitle),
            const SizedBox(height: 8),
            for (final phone in form.phones)
              ContactActionRow(
                icon: Icons.phone_outlined,
                title: Text(phone, overflow: TextOverflow.ellipsis),
                copyValue: phone,
                trailing: PhoneActionButtons(phone: phone),
              ),
            const SizedBox(height: 24),
          ],
          ContactNostrSection(contact: displayedContact),
        ],
      );
    });
  }
}
