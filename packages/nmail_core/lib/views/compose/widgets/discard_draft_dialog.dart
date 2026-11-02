import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Pops `true` when the email being written should be thrown away.
class DiscardDraftDialog extends StatelessWidget {
  const DiscardDraftDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.composeDiscardDraftTitle),
      content: Text(l.composeDiscardDraftMessage),
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
