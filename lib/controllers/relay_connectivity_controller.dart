import 'dart:async';

import 'package:get/get.dart';
import 'package:ndk/entities.dart';

import '../services/nostr_mail_service.dart';

class RelayConnectivityController extends GetxController {
  StreamSubscription<Map<String, RelayConnectivity>>? _subscription;
  Map<String, RelayConnectivity> connectivityMap = {};
  bool isExpanded = false;

  int get connectedCount =>
      connectivityMap.values.where((c) => c.isConnected).length;

  @override
  void onInit() {
    super.onInit();
    _subscribeToConnectivity();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void setExpanded(bool expanded) {
    isExpanded = expanded;
    update();
  }

  void _subscribeToConnectivity() {
    final nostrMailService = Get.find<NostrMailService>();
    _subscription = nostrMailService.relayConnectivityChanges.listen((map) {
      if (isClosed) return;
      connectivityMap = map;
      update();
    });
  }
}
