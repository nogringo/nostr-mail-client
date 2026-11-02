import 'package:flutter/foundation.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/email_delivery_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

/// What a sent email says about its delivery, or null once every recipient
/// has it. Read under [emailDeliverySummaryListenable] to follow name changes.
String? emailDeliverySummary(
  AppLocalizations l,
  EmailDeliveryController delivery,
) {
  if (delivery.hasFailed) return emailNotDeliveredSummary(l, delivery);
  if (delivery.isPending) {
    return delivery.isDeviceOffline
        ? l.emailDeliveryWaitingForNetwork
        : l.emailDeliverySending;
  }
  return null;
}

/// Names the recipients that did not get the email.
String emailNotDeliveredSummary(
  AppLocalizations l,
  EmailDeliveryController delivery,
) => l.emailDeliveryNotDeliveredTo(
  delivery.failedRecipients.map(_name).join(', '),
);

/// Notifies when the delivery or a name [emailDeliverySummary] reads changes.
Listenable emailDeliverySummaryListenable(EmailDeliveryController delivery) =>
    Listenable.merge([
      delivery,
      for (final recipient in delivery.failedRecipients)
        if (!recipient.isBridge)
          emailPersonNameListenable(EmailPerson.nostr(recipient.pubkey)),
    ]);

String _name(RecipientDelivery recipient) => recipient.isBridge
    ? recipient.smtpAddresses.join(', ')
    : emailPersonName(EmailPerson.nostr(recipient.pubkey));
