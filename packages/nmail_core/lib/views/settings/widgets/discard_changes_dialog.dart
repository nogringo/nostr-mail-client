import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Asks before leaving a settings screen that still holds unsaved edits.
/// Pops `true` when the edits should be thrown away.
class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.discardChangesTitle),
      content: Text(l.discardChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionKeepEditing),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.actionDiscard),
        ),
      ],
    );
  }
}
