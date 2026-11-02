import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// Tells the user when an email sent before its recipient's relays could be
/// looked up, offline for one, turns out to have nowhere to go. The compose is
/// long closed by then.
class DeliveryAlertService {
  DeliveryAlertService({BuildContext? Function()? context})
    : _context = context ?? (() => AppRouter.rootContext);

  final BuildContext? Function() _context;
  StreamSubscription<UnreachableDelivery>? _subscription;

  void start() {
    _subscription = GetIt.I<NostrMailService>().client
        .watchUnreachableDeliveries()
        .listen(_alert);
  }

  void dispose() => _subscription?.cancel();

  void _alert(UnreachableDelivery delivery) {
    final context = _context();
    if (context == null) return;
    final l = AppLocalizations.of(context);

    final String reason;
    if (delivery.recipientPubkey == delivery.senderPubkey) {
      reason = l.composeSenderUnreachable;
    } else {
      final name = delivery.smtpAddresses.isNotEmpty
          ? delivery.smtpAddresses.join(', ')
          : emailPersonName(EmailPerson.nostr(delivery.recipientPubkey));
      reason = l.composeRecipientsUnreachable(1, name);
    }
    ToastHelper.error(
      context,
      l.emailDeliveryNotDelivered,
      description: reason,
    );
  }
}
