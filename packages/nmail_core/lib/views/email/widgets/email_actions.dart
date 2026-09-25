import 'package:flutter/material.dart';

import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../email_controller.dart';

class EmailAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const EmailAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

class EmailActions {
  final List<EmailAction> primary;
  final EmailAction delete;

  const EmailActions({required this.primary, required this.delete});
}

/// `mailbox` is null for share-link entry (`/:nostrId`): no known mailbox
/// context, so mailbox-specific actions (mark-read, archive/unarchive)
/// are conservatively hidden.
EmailActions buildEmailActions(
  BuildContext context,
  AppLocalizations l,
  EmailController controller,
  Mailbox? mailbox,
) {
  final showsUnread = mailbox?.showsUnread ?? false;
  final isInArchive = mailbox?.isArchive ?? false;
  final isInTrash = mailbox?.isTrash ?? false;
  final isUnknown = mailbox == null;
  final canFile = !isInTrash && controller.summary != null;

  return EmailActions(
    primary: [
      EmailAction(
        icon: Icons.reply,
        label: l.emailActionReply,
        onPressed: controller.replyEmail,
      ),
      if (controller.shouldShowReplyAll)
        EmailAction(
          icon: Icons.reply_all,
          label: l.emailActionReplyAll,
          onPressed: controller.replyAllEmail,
        ),
      EmailAction(
        icon: Icons.forward,
        label: l.emailActionForward,
        onPressed: controller.forwardEmail,
      ),
      if (isInArchive)
        EmailAction(
          icon: Icons.unarchive,
          label: l.emailActionUnarchive,
          onPressed: controller.unarchiveEmail,
        )
      else if (!isInTrash && !isUnknown)
        EmailAction(
          icon: Icons.archive,
          label: l.emailActionArchive,
          onPressed: controller.archiveEmail,
        ),
      if (canFile) ...[
        EmailAction(
          icon: Icons.drive_file_move_outlined,
          label: l.mailboxMoveTo,
          onPressed: () => controller.moveTo(context),
        ),
        EmailAction(
          icon: Icons.label_outline,
          label: l.mailboxTags,
          onPressed: () => controller.editTags(context),
        ),
      ],
      if (showsUnread)
        EmailAction(
          icon: controller.isEmailRead
              ? Icons.mark_email_unread
              : Icons.mark_email_read,
          label: controller.isEmailRead
              ? l.emailActionMarkUnread
              : l.emailActionMarkRead,
          onPressed: controller.toggleReadStatus,
        ),
      EmailAction(
        icon: Icons.info_outline,
        label: l.emailActionNip59,
        onPressed: controller.showNip59Events,
      ),
      EmailAction(
        icon: Icons.repeat,
        label: l.emailActionRepost,
        onPressed: controller.repostEmail,
      ),
      EmailAction(
        icon: Icons.download,
        label: l.emailActionDownload,
        onPressed: controller.downloadEmail,
      ),
      EmailAction(
        icon: Icons.code,
        label: l.emailActionViewSource,
        onPressed: controller.showEmailSource,
      ),
    ],
    delete: EmailAction(
      icon: Icons.delete_outline,
      label: l.actionDelete,
      onPressed: () => controller.deleteEmail(context),
    ),
  );
}
