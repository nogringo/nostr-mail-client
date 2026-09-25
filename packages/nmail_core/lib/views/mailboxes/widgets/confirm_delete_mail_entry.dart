import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/views/inbox/widgets/delete_permanently_dialog.dart';

/// Says how many emails the deletion touches, then empties and deletes the
/// folder or tag.
Future<void> confirmDeleteMailEntry(
  BuildContext context, {
  required MailEntryKind kind,
  required MailEntry entry,
}) async {
  final l = AppLocalizations.of(context);
  final mailboxes = Get.find<MailboxesController>();
  final count = await mailboxes.countHeld(kind, entry.id);
  if (!context.mounted) return;

  await DeletePermanentlyDialog.confirmAndDelete(
    context,
    title: l.mailboxDeleteTitle(entry.name),
    message: switch (kind) {
      MailEntryKind.folder => l.mailboxDeleteFolderMessage(count),
      MailEntryKind.tag => l.mailboxDeleteTagMessage(count),
    },
    confirmLabel: l.actionDelete,
    delete: () async {
      _leave(switch (kind) {
        MailEntryKind.folder => FolderMailbox(entry.id),
        MailEntryKind.tag => TagMailbox(entry.id),
      });
      await mailboxes.delete(kind, entry.id);
    },
  );
}

void _leave(Mailbox mailbox) {
  final path = AppRoutes.mailboxPath(mailbox);
  final location =
      AppRouter.router.routerDelegate.currentConfiguration.uri.path;
  if (location == path || location.startsWith('$path/')) {
    AppRouter.router.go(AppRoutes.inbox);
  }
}
