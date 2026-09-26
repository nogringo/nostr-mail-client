import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';

/// Pops with a reserved folder name, a user folder id, or [newFolder].
class MoveToDialog extends StatelessWidget {
  /// The mailbox the emails are listed in, left out of the choices.
  final Mailbox? current;

  const MoveToDialog({super.key, required this.current});

  /// Never issued as a folder id.
  static const newFolder = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mailboxes = Get.find<MailboxesController>();
    return SimpleDialog(
      title: Text(l.mailboxMoveTo),
      children: [
        if (current != Mailbox.inbox)
          ListTile(
            leading: const Icon(Icons.inbox_outlined),
            title: Text(l.folderInbox),
            onTap: () => Navigator.pop(context, 'inbox'),
          ),
        if (current != Mailbox.archive)
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(l.folderArchive),
            onTap: () => Navigator.pop(context, 'archive'),
          ),
        for (final folder in mailboxes.folders)
          if (current != FolderMailbox(folder.id))
            ListTile(
              leading: Icon(
                Icons.folder,
                color: MailboxesController.colorOf(
                  folder,
                  on: Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
              ),
              title: Text(folder.name),
              onTap: () => Navigator.pop(context, folder.id),
            ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.create_new_folder_outlined),
          title: Text(l.mailboxNewFolder),
          onTap: () => Navigator.pop(context, newFolder),
        ),
      ],
    );
  }
}
