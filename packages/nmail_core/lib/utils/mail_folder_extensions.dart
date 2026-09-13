import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

extension MailFolderTitle on MailFolder {
  String title(AppLocalizations l) => switch (this) {
    MailFolder.inbox => l.folderInbox,
    MailFolder.sent => l.folderSent,
    MailFolder.trash => l.folderTrash,
    MailFolder.archive => l.folderArchive,
  };
}
