import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'show_contact_form.dart';

class ContactActions extends StatelessWidget {
  final AddressBookContact contact;
  final VoidCallback? onDeleted;

  const ContactActions({super.key, required this.contact, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ContactsController>();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final copied = controller.copiedVCardUid.value == contact.uid;
            return IconButton(
              icon: Icon(copied ? Icons.check : Icons.copy),
              tooltip: copied ? l.contactsVCardCopied : l.contactsCopyVCard,
              onPressed: () => controller.copyVCard(contact),
            );
          }),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: l.contactsEdit,
            onPressed: () => showContactForm(context, contact: contact),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l.contactsDelete,
            onPressed: () => _confirmDelete(context, controller, l),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ContactsController controller,
    AppLocalizations l,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.contactsDeleteTitle),
        content: Text(l.contactsDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.contactsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.contactsDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteContact(contact);
      onDeleted?.call();
    }
  }
}
