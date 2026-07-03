import 'package:flutter/material.dart';

import '../../../controllers/inbox_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
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

/// `folder` is null for share-link entry (`/:nostrId`): no known folder
/// context, so folder-specific actions (mark-read, archive/unarchive)
/// are conservatively hidden.
EmailActions buildEmailActions(
  AppLocalizations l,
  EmailController controller,
  MailFolder? folder,
) {
  final isInbox = folder == MailFolder.inbox;
  final isInArchive = folder == MailFolder.archive;
  final isInTrash = folder == MailFolder.trash;
  final isUnknown = folder == null;

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
      if (isInbox)
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
    ],
    delete: EmailAction(
      icon: Icons.delete_outline,
      label: l.actionDelete,
      onPressed: controller.deleteEmail,
    ),
  );
}
