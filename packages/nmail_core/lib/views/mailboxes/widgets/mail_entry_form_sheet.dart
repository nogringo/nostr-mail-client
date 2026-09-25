import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'mail_entry_form_fields.dart';
import 'mail_entry_form_title.dart';
import 'mail_entry_save_error.dart';

/// The folder or tag form in a centered dialog, on wide layouts.
class MailEntryFormSheet extends StatelessWidget {
  final MailEntryFormController controller;

  const MailEntryFormSheet({super.key, required this.controller});

  static const _gutter = 24.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    mailEntryFormTitle(l, controller),
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
          ),
          const SizedBox(height: 8),
          Flexible(
            // Margins sit inside the scroll view, which clips: the scrollbar
            // runs along the dialog edge, and the first field's floating label
            // keeps room above it.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, 0),
              child: MailEntryFormFields(
                controller: controller,
                onSubmitted: () => _save(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: MailEntrySaveError(controller: controller),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                Obx(
                  () => TextButton(
                    onPressed: controller.isSaving.value
                        ? null
                        : () => Navigator.pop(context),
                    child: Text(l.actionCancel),
                  ),
                ),
                Obx(
                  () => FilledButton(
                    onPressed:
                        controller.isSaving.value || !controller.canSave.value
                        ? null
                        : () => _save(context),
                    child: Text(l.actionSave),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final saved = await controller.save();
    if (saved != null && context.mounted) Navigator.pop(context, saved);
  }
}
