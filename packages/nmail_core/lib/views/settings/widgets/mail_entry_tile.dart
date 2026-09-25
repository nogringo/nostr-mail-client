import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/mail_match_format.dart';
import '../../mailboxes/widgets/confirm_delete_mail_entry.dart';
import '../../mailboxes/widgets/show_mail_entry_form.dart';

class MailEntryTile extends StatelessWidget {
  final MailEntryKind kind;
  final MailEntry entry;
  final int index;

  const MailEntryTile({
    super.key,
    required this.kind,
    required this.entry,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final match = entry.match;
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Icon(switch (kind) {
            MailEntryKind.folder => Icons.folder,
            MailEntryKind.tag => Icons.label,
          }, color: MailboxesController.colorOf(entry)),
        ],
      ),
      title: Text(entry.name, overflow: TextOverflow.ellipsis),
      subtitle: match == null
          ? null
          : Text(
              describeMailMatch(l, match),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l.actionDelete,
        onPressed: () =>
            confirmDeleteMailEntry(context, kind: kind, entry: entry),
      ),
      onTap: () => showMailEntryForm(context, kind: kind, entry: entry),
    );
  }
}
