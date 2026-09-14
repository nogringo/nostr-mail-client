import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class DeletePermanentlyDialog extends StatelessWidget {
  const DeletePermanentlyDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;

  /// Asks for confirmation, then runs [delete] and reports a failure as a toast.
  static Future<void> confirmAndDelete(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() delete,
  }) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeletePermanentlyDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
      ),
    );
    if (confirmed != true) return;

    try {
      await delete();
    } catch (e) {
      if (context.mounted) {
        ToastHelper.error(
          context,
          l.inboxDeleteFailed,
          description: l.inboxDeleteFailedDescription(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
