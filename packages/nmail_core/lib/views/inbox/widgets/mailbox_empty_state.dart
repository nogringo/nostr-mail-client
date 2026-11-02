import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';

/// Stands in for the email list of an empty mailbox. It scrolls so that
/// pulling it down syncs, as on the list.
class MailboxEmptyState extends StatelessWidget {
  final Mailbox mailbox;
  final bool isSearching;
  final Future<void> Function() onRefresh;

  const MailboxEmptyState({
    super.key,
    required this.mailbox,
    required this.isSearching,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final (icon, message) = switch (mailbox) {
      SystemMailbox(folder: MailFolder.inbox) => (
        Icons.inbox_outlined,
        l.inboxEmptyInbox,
      ),
      SystemMailbox(folder: MailFolder.requests) => (
        Icons.how_to_reg_outlined,
        l.inboxEmptyRequests,
      ),
      SystemMailbox(folder: MailFolder.sent) => (
        Icons.send_outlined,
        l.inboxEmptySent,
      ),
      SystemMailbox(folder: MailFolder.trash) => (
        Icons.delete_outlined,
        l.inboxEmptyTrash,
      ),
      SystemMailbox(folder: MailFolder.archive) => (
        Icons.archive_outlined,
        l.inboxEmptyArchive,
      ),
      SystemMailbox(folder: MailFolder.spam) => (
        Icons.report_outlined,
        l.inboxEmptySpam,
      ),
      FolderMailbox() => (Icons.folder_outlined, l.mailboxEmptyFolder),
      TagMailbox() => (Icons.label_outline, l.mailboxEmptyTag),
    };

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: color),
                ),
                if (mailbox.isRequests && !isSearching) ...[
                  const SizedBox(height: 8),
                  Text(
                    l.inboxEmptyRequestsHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ],
                if (mailbox.isInbox) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRefresh,
                    child: Text(l.inboxSyncFromRelays),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
