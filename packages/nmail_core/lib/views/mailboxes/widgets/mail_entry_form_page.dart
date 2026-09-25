import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'mail_entry_form_fields.dart';
import 'mail_entry_form_title.dart';
import 'mail_entry_save_error.dart';

/// The folder or tag form as a full-screen dialog, on phones.
class MailEntryFormPage extends StatelessWidget {
  final MailEntryFormController controller;

  const MailEntryFormPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        // AppBar only centers a leading that is itself an IconButton.
        leading: Center(
          child: Obx(
            () => IconButton(
              icon: const Icon(Icons.close),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: controller.isSaving.value
                  ? null
                  : () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(mailEntryFormTitle(l, controller)),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          Obx(
            () => FilledButton(
              onPressed: controller.isSaving.value || !controller.canSave.value
                  ? null
                  : () => _save(context),
              child: Text(l.actionSave),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MailEntryFormFields(
                controller: controller,
                onSubmitted: () => _save(context),
              ),
              MailEntrySaveError(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.save();
    if (saved != null && context.mounted) Navigator.pop(context, saved);
  }
}
