import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/views/mailboxes/widgets/show_mail_entry_form.dart';

/// The folders the menu's emails can move to, the one listed left out.
class EmailMoveToSubmenu extends StatelessWidget {
  /// Moves the menu's emails to a reserved folder or a user folder id.
  final Future<void> Function(String folder) onMove;

  /// Outlives the menu, to open the new folder form once it closes.
  final BuildContext actionContext;

  const EmailMoveToSubmenu({
    super.key,
    required this.onMove,
    required this.actionContext,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final mailboxes = GetIt.I<MailboxesController>();
    final current = GetIt.I<InboxController>().currentMailbox;
    return ListenableBuilder(
      listenable: mailboxes,
      builder: (context, _) => SubmenuButton(
        leadingIcon: const Icon(Icons.drive_file_move_outlined),
        menuChildren: [
          // Archive and Unarchive sit next to this submenu.
          if (current != Mailbox.inbox && !current.isArchive)
            MenuItemButton(
              leadingIcon: const Icon(Icons.inbox_outlined),
              onPressed: () => onMove('inbox'),
              child: Text(l.folderInbox),
            ),
          for (final folder in mailboxes.folders)
            if (current != FolderMailbox(folder.id))
              MenuItemButton(
                leadingIcon: Icon(
                  Icons.folder,
                  color: MailboxesController.colorOf(
                    folder,
                    on: colorScheme.surfaceContainer,
                  ),
                ),
                onPressed: () => onMove(folder.id),
                child: Text(folder.name),
              ),
          const Divider(height: 1),
          MenuItemButton(
            leadingIcon: const Icon(Icons.create_new_folder_outlined),
            onPressed: _createFolder,
            child: Text(l.mailboxNewFolder),
          ),
        ],
        child: Text(l.mailboxMoveTo),
      ),
    );
  }

  Future<void> _createFolder() async {
    final created = await showMailEntryForm(
      actionContext,
      kind: MailEntryKind.folder,
    );
    if (created == null) return;
    await onMove(created.id);
  }
}
