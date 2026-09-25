import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class MailEntrySaveError extends StatelessWidget {
  final MailEntryFormController controller;

  const MailEntrySaveError({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.error.value != MailEntryFormError.saveFailed) {
        return const SizedBox.shrink();
      }
      return Text(
        l.mailboxSaveFailed,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    });
  }
}
