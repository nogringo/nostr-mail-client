import 'dart:async';

import 'package:get/get.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class RelayConnectivityController extends GetxController {
  final _device = Get.find<DeviceConnectivityService>();

  StreamSubscription<Map<String, RelayConnectivity>>? _subscription;
  Worker? _deviceWorker;
  Map<String, RelayConnectivity> connectivityMap = {};

  int get connectedCount =>
      connectivityMap.values.where((c) => c.isConnected).length;

  /// Only claimed alongside dead relays: the OS verdict comes from an internet
  /// probe on Linux and Windows, which a firewall can fail on a working network.
  bool get isDeviceOffline => _device.isOffline.value && connectedCount == 0;

  @override
  void onInit() {
    super.onInit();
    _subscribeToConnectivity();
    _deviceWorker = ever(_device.isOffline, (_) => update());
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _deviceWorker?.dispose();
    super.onClose();
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
