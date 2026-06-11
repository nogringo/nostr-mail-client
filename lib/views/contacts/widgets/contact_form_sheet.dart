import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/contact_form_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'contact_form_fields.dart';

class ContactFormSheet extends StatelessWidget {
  final ContactFormController controller;

  const ContactFormSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
              ContactFormFields(controller: controller),
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
                      onPressed:
                          controller.isSaving.value || !controller.canSave.value
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
