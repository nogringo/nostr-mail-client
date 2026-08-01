import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'language_options_list.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      // The default dialog surface is surfaceContainerHigh, the tile colour itself.
      backgroundColor: colorScheme.surfaceContainerLow,
      title: Text(l.settingsLanguageDialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: const SizedBox(
        width: 320,
        child: SingleChildScrollView(child: LanguageOptionsList()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }
}
