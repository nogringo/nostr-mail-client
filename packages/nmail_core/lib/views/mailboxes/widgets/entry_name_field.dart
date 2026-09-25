import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class EntryNameField extends StatelessWidget {
  final MailEntryFormController controller;
  final VoidCallback onSubmitted;

  const EntryNameField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Obx(
      () => TextField(
        controller: controller.nameController,
        autofocus: !controller.isEditing,
        maxLength: MailEntryFormController.maxNameLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(
          labelText: l.mailboxName,
          errorText: controller.error.value == MailEntryFormError.nameTaken
              ? l.mailboxNameTaken
              : null,
        ),
      ),
    );
  }
}
