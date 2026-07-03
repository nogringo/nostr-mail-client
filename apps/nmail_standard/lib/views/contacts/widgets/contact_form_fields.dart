import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contact_form_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import '../../../widgets/nostr_avatar.dart';
import 'contact_birthday_field.dart';
import 'contact_methods_field.dart';
import 'nostr_identity_label.dart';
import 'quiet_field.dart';

class ContactFormFields extends StatelessWidget {
  final ContactFormController controller;

  const ContactFormFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuietField(
          label: l.contactsNameLabel,
          controller: controller.nameController,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        ContactBirthdayField(controller: controller),
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
            label: l.contactsPhonesLabel,
            hintText: l.contactsAddPhoneHint,
            values: controller.phones.toList(),
            controller: controller.phoneInputController,
            keyboardType: TextInputType.phone,
            addTooltip: l.actionAdd,
            onAdd: controller.addPhoneFromInput,
            onRemove: controller.removePhone,
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
              final pubkey = AddressBookVCardMapper.normalizeNostrPubkey(value);
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
            child: Text(error, style: TextStyle(color: colorScheme.error)),
          );
        }),
      ],
    );
  }
}
