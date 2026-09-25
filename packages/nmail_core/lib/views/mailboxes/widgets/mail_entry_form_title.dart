import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';

String mailEntryFormTitle(
  AppLocalizations l,
  MailEntryFormController controller,
) => switch ((controller.kind, controller.isEditing)) {
  (MailEntryKind.folder, false) => l.mailboxNewFolder,
  (MailEntryKind.folder, true) => l.mailboxEditFolder,
  (MailEntryKind.tag, false) => l.mailboxNewTag,
  (MailEntryKind.tag, true) => l.mailboxEditTag,
};
