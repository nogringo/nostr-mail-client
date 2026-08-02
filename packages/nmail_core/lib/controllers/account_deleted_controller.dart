import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';

import 'package:nmail_core/utils/relay_utils.dart';

/// Follows one queued request to vanish as the relays answer it.
class AccountDeletedController extends GetxController {
  AccountDeletedController({required this.requestId});

  final String requestId;

  StreamSubscription<QueuedBroadcast?>? _subscription;
  QueuedBroadcast? request;

  List<String> get relays {
    final urls = List<String>.from(request?.relays ?? const <String>[]);
    // Alphabetical, so a row never moves as its status changes.
    urls.sort((a, b) => formatRelayUrl(a).compareTo(formatRelayUrl(b)));
    return urls;
  }

  int get erasedCount => request?.ackedRelays.length ?? 0;

  int get relayCount => request?.relays.length ?? 0;

  bool get hasPendingRelays => request?.remainingRelays.isNotEmpty ?? false;

  bool isErased(String relay) => request?.ackedRelays.contains(relay) ?? false;

  /// A relay the queue has given up on, whether it turned the request down or
  /// stayed out of reach. Both leave the data where it is.
  bool isNotErased(String relay) =>
      request?.terminalErrors.containsKey(relay) ?? false;

  @override
  void onInit() {
    super.onInit();
    _subscription = Get.find<OfflineBroadcast>().watch(requestId).listen((
      record,
    ) {
      if (isClosed) return;
      request = record;
      update();
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
