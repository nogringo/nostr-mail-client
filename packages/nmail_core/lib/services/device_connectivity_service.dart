import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

/// What the OS says about the device's network, and the one place that acts on
/// it by forcing NDK's relays to reconnect.
///
/// NDK parks a relay that failed to connect behind
/// `FAIL_RELAY_CONNECT_TRY_AFTER_SECONDS` (60s) and `requests.query` never
/// forces, so without a nudge the app stays dark for a minute after the network
/// comes back. `tryReconnect` passes `force: true`, which is the only way
/// through.
class DeviceConnectivityService extends GetxService {
  DeviceConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// True while the OS reports no network interface at all.
  ///
  /// Not a reachability verdict in either direction. False only means an
  /// interface exists, and on Linux and Windows even the true is untrustworthy:
  /// both derive it from an internet probe (NetworkManager's nmcheck, Windows
  /// NCSI), which a firewall can fail on a perfectly working network. Read it
  /// alongside relay connectivity, never alone.
  final isOffline = false.obs;

  static const _debounce = Duration(seconds: 3);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  AppLifecycleListener? _lifecycle;
  Timer? _debounceTimer;
  Completer<void>? _scheduled;
  Completer<void>? _rerun;
  Future<void>? _pass;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _setOffline(!results.hasConnectivity),
      onError: (_) => _setOffline(false),
    );
    _lifecycle = AppLifecycleListener(onResume: _handleResume);
    unawaited(_refresh());
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _lifecycle?.dispose();
    _debounceTimer?.cancel();
    // Release anyone awaiting a pass that will now never run.
    _scheduled?.complete();
    _rerun?.complete();
    super.onClose();
  }

  /// Reconnects every relay right away. For an explicit user action; anything
  /// reacting to a connectivity edge wants [reconnectSoon] instead.
  ///
  /// A caller arriving mid-pass does not join the pass in flight: that one may
  /// have started before the network returned, and `tryReconnect` awaits each
  /// relay in turn (4s apiece offline), so joining it can mean waiting out an
  /// attempt that is already doomed. It gets a fresh pass chained on instead.
  Future<void> reconnectNow() {
    if (_pass == null) return _startPass();
    return (_rerun ??= Completer<void>()).future;
  }

  /// [reconnectNow], debounced. Wi-Fi association and Android's
  /// `onAvailable`/`onCapabilitiesChanged` split both announce a network before
  /// it carries traffic, and a force-reconnect that fires too early re-arms
  /// NDK's 60s backoff on every relay.
  ///
  /// The returned future completes once the resulting pass has settled, so a
  /// caller can await the reconnect the edge already scheduled rather than
  /// racing it with one of its own.
  Future<void> reconnectSoon() {
    final scheduled = _scheduled ??= Completer<void>();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      _scheduled = null;
      reconnectNow().whenComplete(() => scheduled.complete());
    });
    return scheduled.future;
  }

  /// A drop and return that happens entirely in the background produces no
  /// edge to react to: Android stopped broadcasting connectivity changes to
  /// backgrounded apps in 8.0. So resume reconnects on its own evidence rather
  /// than going through [_setOffline], which would see no change and do
  /// nothing while every socket is dead.
  void _handleResume() {
    unawaited(_refresh());
    if (!isOffline.value) unawaited(reconnectNow());
  }

  Future<void> _refresh() async {
    try {
      // Linux D-Bus and Windows COM can wedge rather than throw. An empty list
      // reads as "unknown", and unknown is not offline.
      final results = await _connectivity.checkConnectivity().timeout(
        const Duration(seconds: 3),
        onTimeout: () => const [],
      );
      _setOffline(!results.hasConnectivity);
    } catch (_) {
      _setOffline(false);
    }
  }

  void _setOffline(bool offline) {
    if (offline == isOffline.value) return;
    isOffline.value = offline;
    if (!offline) unawaited(reconnectSoon());
  }

  Future<void> _startPass() {
    final pass = _runPass();
    _pass = pass;
    pass.whenComplete(() {
      _pass = null;
      final rerun = _rerun;
      if (rerun == null) return;
      _rerun = null;
      _startPass().whenComplete(() => rerun.complete());
    });
    return pass;
  }

  /// Never completes with an error: both callers fire it unawaited, and NDK
  /// lets a throw from one relay abandon the rest of its serial loop.
  Future<void> _runPass() async {
    try {
      await Get.find<Ndk>().connectivity.tryReconnect();
    } catch (_) {
      //
    }
  }
}
