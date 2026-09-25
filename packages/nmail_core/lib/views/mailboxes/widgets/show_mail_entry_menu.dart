import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/views/shared/show_context_menu.dart';
import 'confirm_delete_mail_entry.dart';
import 'show_mail_entry_form.dart';

enum _MailEntryAction { edit, delete }

/// Edit or delete a folder or tag: a menu at [position] on a right click, a
/// bottom sheet on a long press.
Future<void> showMailEntryMenu(
  BuildContext context, {
  required MailEntryKind kind,
  required MailEntry entry,
  Offset? position,
}) async {
  final l = AppLocalizations.of(context);
  final colorScheme = Theme.of(context).colorScheme;
  final deleteStyle = TextStyle(color: colorScheme.error);
  final deleteIcon = Icon(Icons.delete_outline, color: colorScheme.error);

  final action = position != null
      ? await showContextMenu<_MailEntryAction>(
          context,
          position: position,
          children: (menuContext) => [
            MenuItemButton(
              leadingIcon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Navigator.pop(menuContext, _MailEntryAction.edit),
              child: Text(l.mailboxEdit),
            ),
            MenuItemButton(
              leadingIcon: deleteIcon,
              onPressed: () =>
                  Navigator.pop(menuContext, _MailEntryAction.delete),
              child: Text(l.actionDelete, style: deleteStyle),
            ),
          ],
        )
      : await showModalBottomSheet<_MailEntryAction>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l.mailboxEdit),
                  onTap: () =>
                      Navigator.pop(sheetContext, _MailEntryAction.edit),
                ),
                ListTile(
                  leading: deleteIcon,
                  title: Text(l.actionDelete, style: deleteStyle),
                  onTap: () =>
                      Navigator.pop(sheetContext, _MailEntryAction.delete),
                ),
              ],
            ),
          ),
        );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _MailEntryAction.edit:
      await showMailEntryForm(context, kind: kind, entry: entry);
    case _MailEntryAction.delete:
      await confirmDeleteMailEntry(context, kind: kind, entry: entry);
  }
}
