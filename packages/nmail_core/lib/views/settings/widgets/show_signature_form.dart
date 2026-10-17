import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'signature_form_page.dart';
import 'signature_form_sheet.dart';

/// Creates a signature, edits [signature], or turns [legacyText] into the
/// first one. Returns the saved signature, or null when dismissed.
Future<Signature?> showSignatureForm(
  BuildContext context, {
  Signature? signature,
  String? legacyText,
}) async {
  final controller = SignatureFormController(
    signatures: GetIt.I<SignaturesController>(),
    signature: signature,
    legacyText: legacyText,
    legacyName: AppLocalizations.of(context).signaturesLegacyName,
  );
  ModalRoute<Object?>? route;
  try {
    return await showDialog<Signature>(
      context: context,
      builder: (dialogContext) {
        route = ModalRoute.of(dialogContext);
        return ResponsiveHelper.isNotMobile(context)
            ? Dialog(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SignatureFormSheet(controller: controller),
                ),
              )
            : Dialog.fullscreen(
                child: SignatureFormPage(controller: controller),
              );
      },
    );
  } finally {
    // The fields keep building through the exit animation, so their
    // controllers are disposed once the route is gone, not on pop.
    final shown = route;
    if (shown == null) {
      controller.dispose();
    } else {
      shown.completed.then((_) => controller.dispose());
    }
  }
}
