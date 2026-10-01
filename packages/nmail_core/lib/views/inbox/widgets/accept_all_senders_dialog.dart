import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class AcceptAllSendersDialog extends StatelessWidget {
  final int senderCount;

  const AcceptAllSendersDialog({super.key, required this.senderCount});

  static Future<bool> confirm(BuildContext context, int senderCount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AcceptAllSendersDialog(senderCount: senderCount),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.requestsAcceptAllTitle),
      content: Text(l.requestsAcceptAllMessage(senderCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.requestsAcceptAll),
        ),
      ],
    );
  }
}
