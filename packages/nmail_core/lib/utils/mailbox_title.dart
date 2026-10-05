import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';

extension MailboxTitle on Mailbox {
  /// A user folder or tag with no entry shows under its id, as the spec asks.
  String title(AppLocalizations l) => switch (this) {
    SystemMailbox(folder: MailFolder.inbox) => l.folderInbox,
    SystemMailbox(folder: MailFolder.requests) => l.folderRequests,
    SystemMailbox(folder: MailFolder.sent) => l.folderSent,
    SystemMailbox(folder: MailFolder.trash) => l.folderTrash,
    SystemMailbox(folder: MailFolder.archive) => l.folderArchive,
    SystemMailbox(folder: MailFolder.spam) => l.folderSpam,
    FolderMailbox(:final id) =>
      GetIt.I<MailboxesController>().folderById(id)?.name ?? id,
    TagMailbox(:final id) =>
      GetIt.I<MailboxesController>().tagById(id)?.name ?? id,
  };
}
