import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contact_form_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'contact_methods_field.dart';
import '../../../utils/address_book_vcard_mapper.dart';
import '../../../widgets/nostr_avatar.dart';
import 'nostr_identity_label.dart';
import 'quiet_field.dart';

class ContactFormSheet extends StatelessWidget {
  final String controllerTag;

  const ContactFormSheet({super.key, required this.controllerTag});

  ContactFormController get controller =>
      Get.find<ContactFormController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.isEditing
                          ? l.contactsEditTitle
                          : l.contactsCreateTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: controller.isSaving.value
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              QuietField(
                label: l.contactsNameLabel,
                controller: controller.nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              Obx(
                () => ContactMethodsField(
                  label: l.contactsEmailsLabel,
                  hintText: l.contactsAddEmailHint,
                  values: controller.emails.toList(),
                  controller: controller.emailInputController,
                  keyboardType: TextInputType.emailAddress,
                  addTooltip: l.actionAdd,
                  onAdd: controller.addEmailFromInput,
                  onRemove: controller.removeEmail,
                ),
              ),
              const SizedBox(height: 14),
              Obx(
                () => ContactMethodsField(
                  label: l.contactsNostrLabel,
                  hintText: l.contactsAddNostrHint,
                  values: controller.nostrIdentifiers.toList(),
                  controller: controller.nostrInputController,
                  addTooltip: l.actionAdd,
                  labelBuilder: (value) => NostrIdentityName(identifier: value),
                  avatarBuilder: (value) {
                    final pubkey = AddressBookVCardMapper.normalizeNostrPubkey(
                      value,
                    );
                    if (pubkey == null) return null;
                    return NostrAvatar(pubkey: pubkey, radius: 10);
                  },
                  onAdd: controller.addNostrFromInput,
                  onRemove: controller.removeNostrIdentifier,
                ),
              ),
              Obx(() {
                final error = controller.error.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error,
                    style: TextStyle(color: colorScheme.error),
                  ),
                );
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => TextButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(l.contactsCancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => FilledButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () => _save(context),
                      child: Text(l.contactsSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.save();
    if (saved && context.mounted) {
      Navigator.pop(context);
    }
  }
}
