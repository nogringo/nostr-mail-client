import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import '../../mailboxes/widgets/show_mail_entry_form.dart';

class MailEntryAddTile extends StatelessWidget {
  final MailEntryKind kind;

  const MailEntryAddTile({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.add),
      title: Text(switch (kind) {
        MailEntryKind.folder => l.mailboxNewFolder,
        MailEntryKind.tag => l.mailboxNewTag,
      }),
      onTap: () => showMailEntryForm(context, kind: kind),
    );
  }
}
