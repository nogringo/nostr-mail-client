import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

/// Follows a Sent email through the queues, recipient by recipient. Says
/// nothing once every recipient has it, nor for an email another device sent.
class EmailDeliveryController extends ChangeNotifier {
  EmailDeliveryController({required this.emailId}) {
    _subscription = _client.watchDelivery(emailId).listen((value) {
      delivery = value;
      notifyListeners();
    });
    _device.isDeviceOffline.addListener(notifyListeners);
  }

  final String emailId;

  late final StreamSubscription<EmailDelivery?> _subscription;
  EmailDelivery? delivery;

  final _device = GetIt.I<DeviceConnectivityService>();

  NostrMailClient get _client => GetIt.I<NostrMailService>().client;

  /// Nothing still sending leaves before the network is back.
  bool get isDeviceOffline => _device.isDeviceOffline.value;

  List<RecipientDelivery> get recipients => delivery?.recipients ?? const [];

  List<RecipientDelivery> get failedRecipients =>
      recipients.where((r) => r.status == DeliveryStatus.failed).toList();

  int get failedCount => failedRecipients.length;

  int get pendingCount =>
      recipients.where((r) => r.status == DeliveryStatus.pending).length;

  bool get hasFailed => failedCount > 0;

  /// Still sending, with nothing refused so far.
  bool get isPending => !hasFailed && pendingCount > 0;

  Future<void> retry() => _client.retryDelivery(emailId);

  @override
  void dispose() {
    _subscription.cancel();
    _device.isDeviceOffline.removeListener(notifyListeners);
    super.dispose();
  }
}
