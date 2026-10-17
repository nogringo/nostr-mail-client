import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

String signatureUseLabel(AppLocalizations l, SignatureUse use) => switch (use) {
  SignatureUse.newEmail => l.signatureUseNew,
  SignatureUse.reply => l.signatureUseReply,
};

/// An id naming no signature means none, as the spec says.
String signatureNameOf(
  AppLocalizations l,
  SignaturesController controller,
  String? id,
) => controller.byId(id)?.name ?? l.signatureNone;

/// The id a picker shows as selected: an empty string for none.
String knownSignatureId(SignaturesController controller, String? id) =>
    controller.byId(id)?.id ?? '';
