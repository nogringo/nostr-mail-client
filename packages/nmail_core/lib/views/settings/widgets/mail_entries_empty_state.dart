import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import '../../mailboxes/widgets/show_mail_entry_form.dart';

class MailEntriesEmptyState extends StatelessWidget {
  final MailEntryKind kind;

  const MailEntriesEmptyState({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (icon, message, action) = switch (kind) {
      MailEntryKind.folder => (
        Icons.folder_outlined,
        l.mailboxNoFolders,
        l.mailboxNewFolder,
      ),
      MailEntryKind.tag => (
        Icons.label_outline,
        l.mailboxNoTags,
        l.mailboxNewTag,
      ),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () => showMailEntryForm(context, kind: kind),
              icon: const Icon(Icons.add),
              label: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}
