import 'package:flutter/material.dart';

import 'package:nmail_core/models/mailbox.dart';
import 'move_to_dialog.dart';
import 'show_mail_entry_form.dart';

/// The folder to move emails to: a reserved folder name or a user folder id,
/// possibly one created on the spot. Null when dismissed.
Future<String?> showMoveToPicker(
  BuildContext context, {
  required Mailbox? current,
}) async {
  final picked = await showDialog<String>(
    context: context,
    builder: (_) => MoveToDialog(current: current),
  );
  if (picked != MoveToDialog.newFolder) return picked;
  if (!context.mounted) return null;
  final created = await showMailEntryForm(context, kind: MailEntryKind.folder);
  return created?.id;
}
