import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/inbox/widgets/delete_permanently_dialog.dart';

Future<void> confirmDeleteSignature(BuildContext context, Signature signature) {
  final l = AppLocalizations.of(context);
  return DeletePermanentlyDialog.confirmAndDelete(
    context,
    title: l.signatureDeleteTitle(signature.name),
    message: l.signatureDeleteMessage,
    confirmLabel: l.actionDelete,
    delete: () => GetIt.I<SignaturesController>().delete(signature.id),
  );
}
