import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/controllers/email_delivery_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/email_delivery_summary.dart';

import '../helpers/fake_metadata_service.dart';

class _FakeNdk implements Ndk {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMailClient implements NostrMailClient {
  final deliveries = StreamController<EmailDelivery?>.broadcast();

  @override
  Stream<EmailDelivery?> watchDelivery(String emailId) => deliveries.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNostrMailService implements NostrMailService {
  _FakeNostrMailService(this.client);

  @override
  final NostrMailClient client;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDevice implements DeviceConnectivityService {
  @override
  final isDeviceOffline = ValueNotifier(false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _en = lookupAppLocalizations(const Locale('en'));

final _alice = 'a' * 64;
final _bob = 'b' * 64;
final _carol = 'c' * 64;
final _bridge = 'd' * 64;

RecipientDelivery _recipient(
  String pubkey,
  DeliveryStatus status, {
  List<String> smtpAddresses = const [],
}) => RecipientDelivery(
  pubkey: pubkey,
  smtpAddresses: smtpAddresses,
  relays: [UrlDelivery(url: 'wss://relay.example', status: status)],
);

void main() {
  late _FakeMailClient client;
  late _FakeDevice device;
  late FakeMetadataService metadata;

  setUp(() {
    GetIt.I.registerSingleton<Ndk>(_FakeNdk());
    client = _FakeMailClient();
    GetIt.I.registerSingleton<NostrMailService>(_FakeNostrMailService(client));
    device = _FakeDevice();
    GetIt.I.registerSingleton<DeviceConnectivityService>(device);
    metadata = FakeMetadataService();
    GetIt.I.registerSingleton<MetadataService>(metadata);
    GetIt.I.registerSingleton(AddressBookService());
    metadata.resolve(Metadata(pubKey: _alice, name: 'Alice'));
    metadata.resolve(Metadata(pubKey: _bob, name: 'Bob'));
    metadata.resolve(Metadata(pubKey: _carol, name: 'Carol'));
  });

  tearDown(() => GetIt.I.reset());

  Future<EmailDeliveryController> deliveryOf(
    List<RecipientDelivery> recipients,
  ) async {
    final delivery = EmailDeliveryController(emailId: 'email');
    addTearDown(delivery.dispose);
    client.deliveries.add(
      EmailDelivery(emailId: 'email', recipients: recipients),
    );
    await pumpEventQueue();
    return delivery;
  }

  test('names the only recipient, who did not get the email', () async {
    final delivery = await deliveryOf([
      _recipient(_alice, DeliveryStatus.failed),
    ]);

    expect(emailDeliverySummary(_en, delivery), 'Not delivered to Alice');
  });

  test('names only the recipients that did not get it', () async {
    final delivery = await deliveryOf([
      _recipient(_alice, DeliveryStatus.failed),
      _recipient(_bob, DeliveryStatus.delivered),
      _recipient(_carol, DeliveryStatus.failed),
    ]);

    expect(
      emailDeliverySummary(_en, delivery),
      'Not delivered to Alice, Carol',
    );
  });

  test('names a bridge by the addresses it relays to', () async {
    final delivery = await deliveryOf([
      _recipient(
        _bridge,
        DeliveryStatus.failed,
        smtpAddresses: ['bob@example.com', 'carol@example.com'],
      ),
    ]);

    expect(
      emailDeliverySummary(_en, delivery),
      'Not delivered to bob@example.com, carol@example.com',
    );
  });

  test('a recipient found with no relay counts as not delivered', () async {
    final delivery = await deliveryOf([
      RecipientDelivery(pubkey: _alice, relays: const [], unreachable: true),
    ]);

    expect(emailDeliverySummary(_en, delivery), 'Not delivered to Alice');
  });

  test('waits for the network while the device is offline', () async {
    final delivery = await deliveryOf([
      _recipient(_alice, DeliveryStatus.pending),
    ]);
    expect(emailDeliverySummary(_en, delivery), 'Sending');

    var notified = false;
    delivery.addListener(() => notified = true);
    device.isDeviceOffline.value = true;

    expect(notified, isTrue);
    expect(emailDeliverySummary(_en, delivery), 'Waiting for network');
  });

  test('says nothing once every recipient has it', () async {
    final delivery = await deliveryOf([
      _recipient(_alice, DeliveryStatus.delivered),
    ]);

    expect(emailDeliverySummary(_en, delivery), isNull);
  });

  test('follows a name that loads after the delivery', () async {
    final dave = 'e' * 64;
    final delivery = await deliveryOf([
      _recipient(dave, DeliveryStatus.failed),
    ]);
    var notified = false;
    emailDeliverySummaryListenable(delivery).addListener(() => notified = true);

    metadata.resolve(Metadata(pubKey: dave, name: 'Dave'));

    expect(notified, isTrue);
    expect(emailDeliverySummary(_en, delivery), 'Not delivered to Dave');
  });
}
