import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/entities.dart';
import 'package:nmail_core/services/device_connectivity_service.dart';

class _FakeConnectivity implements Connectivity {
  var _results = [ConnectivityResult.wifi];
  final _changes = StreamController<List<ConnectivityResult>>.broadcast();

  set results(List<ConnectivityResult> value) {
    _results = value;
    _changes.add(value);
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _changes.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;
}

class _Connection implements RelayConnectivity {
  _Connection({required this.isConnected});

  @override
  final bool isConnected;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeConnectivity os;
  late StreamController<List<RelayConnectivity>> relays;
  late DeviceConnectivityService service;

  setUp(() async {
    os = _FakeConnectivity();
    relays = StreamController.broadcast();
    service = DeviceConnectivityService(
      connectivity: os,
      relayConnectivityChanges: relays.stream,
    );
    await pumpEventQueue();
  });

  tearDown(() async {
    service.dispose();
    await relays.close();
  });

  test('is offline once the OS has no network and no relay is up', () async {
    relays.add([_Connection(isConnected: false)]);
    os.results = [ConnectivityResult.none];
    await pumpEventQueue();

    expect(service.isDeviceOffline.value, isTrue);
  });

  test('stays online while a relay is up, whatever the OS says', () async {
    relays.add([_Connection(isConnected: true)]);
    os.results = [ConnectivityResult.none];
    await pumpEventQueue();

    expect(service.isOffline.value, isTrue);
    expect(service.isDeviceOffline.value, isFalse);
  });

  test('is online again as soon as the OS has a network', () async {
    relays.add([_Connection(isConnected: false)]);
    os.results = [ConnectivityResult.none];
    await pumpEventQueue();
    os.results = [ConnectivityResult.mobile];
    await pumpEventQueue();

    expect(service.isDeviceOffline.value, isFalse);
  });

  test('relays going down alone do not make the device offline', () async {
    relays.add([_Connection(isConnected: true)]);
    relays.add([_Connection(isConnected: false)]);
    await pumpEventQueue();

    expect(service.isDeviceOffline.value, isFalse);
  });
}
