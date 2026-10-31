import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

/// Follows a Sent email through the queues, recipient by recipient. Says
/// nothing once every recipient has it, nor for an email another device sent.
class EmailDeliveryController extends ChangeNotifier {
  EmailDeliveryController({required this.emailId}) {
    _subscription = _client.watchDelivery(emailId).listen((value) {
      delivery = value;
      notifyListeners();
    });
  }

  final String emailId;

  late final StreamSubscription<EmailDelivery?> _subscription;
  EmailDelivery? delivery;

  NostrMailClient get _client => GetIt.I<NostrMailService>().client;

  List<RecipientDelivery> get recipients => delivery?.recipients ?? const [];

  int get failedCount =>
      recipients.where((r) => r.status == DeliveryStatus.failed).length;

  int get pendingCount =>
      recipients.where((r) => r.status == DeliveryStatus.pending).length;

  bool get hasFailed => failedCount > 0;

  /// Still sending, with nothing refused so far.
  bool get isPending => !hasFailed && pendingCount > 0;

  Future<void> retry() => _client.retryDelivery(emailId);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
