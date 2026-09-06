import 'dart:async';

import 'package:get/get.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class RelayConnectivityController extends GetxController {
  final _device = Get.find<DeviceConnectivityService>();

  StreamSubscription<List<RelayConnectivity>>? _subscription;
  Worker? _deviceWorker;

  /// Whether each relay is reachable, by url. NDK opens one connection per
  /// authenticated identity, and a relay listed twice would read as two.
  Map<String, bool> relays = {};

  int get connectedCount =>
      relays.values.where((isConnected) => isConnected).length;

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
    _subscription = nostrMailService.relayConnectivityChanges.listen((
      connections,
    ) {
      if (isClosed) return;
      final byUrl = <String, bool>{};
      for (final connection in connections) {
        byUrl[connection.url] =
            (byUrl[connection.url] ?? false) || connection.isConnected;
      }
      relays = byUrl;
      update();
    });
  }
}
