import 'package:get/get.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';

extension MailboxTitle on Mailbox {
  /// A user folder or tag with no entry shows under its id, as the spec asks.
  String title(AppLocalizations l) => switch (this) {
    SystemMailbox(folder: MailFolder.inbox) => l.folderInbox,
    SystemMailbox(folder: MailFolder.sent) => l.folderSent,
    SystemMailbox(folder: MailFolder.trash) => l.folderTrash,
    SystemMailbox(folder: MailFolder.archive) => l.folderArchive,
    FolderMailbox(:final id) =>
      Get.find<MailboxesController>().folderById(id)?.name ?? id,
    TagMailbox(:final id) =>
      Get.find<MailboxesController>().tagById(id)?.name ?? id,
  };
}
