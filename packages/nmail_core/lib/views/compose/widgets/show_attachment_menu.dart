import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/compose_attachment.dart';
import 'package:nmail_core/views/shared/show_context_menu.dart';
import 'rename_attachment_dialog.dart';

enum _AttachmentAction { rename, remove }

/// Rename or remove a compose attachment: a menu at [position] on a right
/// click, a bottom sheet on a long press.
Future<void> showAttachmentMenu(
  BuildContext context, {
  required ComposeAttachment attachment,
  required ValueChanged<String> onRename,
  required VoidCallback onRemove,
  Offset? position,
}) async {
  final l = AppLocalizations.of(context);

  final action = position != null
      ? await showContextMenu<_AttachmentAction>(
          context,
          position: position,
          children: (menuContext) => [
            MenuItemButton(
              leadingIcon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  Navigator.pop(menuContext, _AttachmentAction.rename),
              child: Text(l.actionRename),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.close),
              onPressed: () =>
                  Navigator.pop(menuContext, _AttachmentAction.remove),
              child: Text(l.actionRemove),
            ),
          ],
        )
      : await showModalBottomSheet<_AttachmentAction>(
          context: context,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l.actionRename),
                  onTap: () =>
                      Navigator.pop(sheetContext, _AttachmentAction.rename),
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(l.actionRemove),
                  onTap: () =>
                      Navigator.pop(sheetContext, _AttachmentAction.remove),
                ),
              ],
            ),
          ),
        );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _AttachmentAction.rename:
      final filename = await showRenameAttachmentDialog(
        context,
        attachment.filename,
      );
      if (filename != null) onRename(filename);
    case _AttachmentAction.remove:
      onRemove();
  }
}
