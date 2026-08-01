import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class ResetApplicationDialog extends StatelessWidget {
  const ResetApplicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l.settingsResetApplication),
      content: Text(l.settingsResetConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: Text(l.actionReset),
        ),
      ],
    );
  }
}
