import 'package:nmail_core/controllers/signature_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

String signatureFormTitle(
  AppLocalizations l,
  SignatureFormController controller,
) => controller.isEditing ? l.signaturesEdit : l.signaturesNew;
