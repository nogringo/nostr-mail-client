import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../controllers/contact_form_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/address_book_contact_form.dart';
import '../../../utils/responsive_helper.dart';
import 'contact_form_fields.dart';

class ContactFormPage extends StatelessWidget {
  final AddressBookContact? contact;
  final AddressBookContactForm? initialForm;

  const ContactFormPage({super.key, this.contact, this.initialForm});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<ContactFormController>(
      init: ContactFormController(contact: contact, initialForm: initialForm),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              controller.isEditing
                  ? l.contactsEditTitle
                  : l.contactsCreateTitle,
            ),
            actionsPadding: const EdgeInsets.only(right: 8),
            actions: [
              Obx(
                () => FilledButton(
                  onPressed:
                      controller.isSaving.value || !controller.canSave.value
                      ? null
                      : () => _save(context, controller),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.contactsSave),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 560,
              padding: const EdgeInsets.all(16),
              child: ContactFormFields(controller: controller),
            ),
          ),
        );
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    ContactFormController controller,
  ) async {
    final saved = await controller.save();
    if (saved && context.mounted) {
      Navigator.pop(context);
    }
  }
}
