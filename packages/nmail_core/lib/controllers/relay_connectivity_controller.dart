import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class RelayConnectivityController extends ChangeNotifier {
  RelayConnectivityController() {
    _subscribeToConnectivity();
    _deviceSubscription = _device.isOffline.listen((_) => notifyListeners());
  }

  final _device = Get.find<DeviceConnectivityService>();

  StreamSubscription<List<RelayConnectivity>>? _subscription;
  late final StreamSubscription<bool> _deviceSubscription;

  /// Whether each relay is reachable, by url. NDK opens one connection per
  /// authenticated identity, and a relay listed twice would read as two.
  Map<String, bool> relays = {};

  int get connectedCount =>
      relays.values.where((isConnected) => isConnected).length;

  /// Only claimed alongside dead relays: the OS verdict comes from an internet
  /// probe on Linux and Windows, which a firewall can fail on a working network.
  bool get isDeviceOffline => _device.isOffline.value && connectedCount == 0;

  @override
  void dispose() {
    _subscription?.cancel();
    _deviceSubscription.cancel();
    super.dispose();
  }

  void _subscribeToConnectivity() {
    final nostrMailService = GetIt.I<NostrMailService>();
    _subscription = nostrMailService.relayConnectivityChanges.listen((
      connections,
    ) {
      final byUrl = <String, bool>{};
      for (final connection in connections) {
        byUrl[connection.url] =
            (byUrl[connection.url] ?? false) || connection.isConnected;
      }
      relays = byUrl;
      notifyListeners();
    });
  }
}
