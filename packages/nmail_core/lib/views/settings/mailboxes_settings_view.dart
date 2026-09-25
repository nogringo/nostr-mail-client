import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'widgets/mail_entries_list.dart';

class MailboxesSettingsView extends StatelessWidget {
  const MailboxesSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.mailboxSettingsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.mailboxFolders),
              Tab(text: l.mailboxTags),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              MailEntriesList(kind: MailEntryKind.folder),
              MailEntriesList(kind: MailEntryKind.tag),
            ],
          ),
        ),
      ),
    );
  }
}
