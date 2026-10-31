import 'package:nmail_core/controllers/email_delivery_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// What a sent email says about its delivery, or null once every recipient
/// has it.
String? emailDeliverySummary(
  AppLocalizations l,
  EmailDeliveryController delivery,
) {
  if (delivery.hasFailed) {
    return l.emailDeliveryNotDeliveredCount(delivery.failedCount);
  }
  if (delivery.isPending) return l.emailDeliverySending;
  return null;
}
