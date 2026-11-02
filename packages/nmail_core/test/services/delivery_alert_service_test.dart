import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:toastification/toastification.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/delivery_alert_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

import '../helpers/fake_metadata_service.dart';

class _FakeNdk implements Ndk {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMailClient implements NostrMailClient {
  final unreachable = StreamController<UnreachableDelivery>.broadcast();

  @override
  Stream<UnreachableDelivery> watchUnreachableDeliveries() =>
      unreachable.stream;

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

final _en = lookupAppLocalizations(const Locale('en'));

final _sender = 'a' * 64;
final _alice = 'b' * 64;
final _bridge = 'c' * 64;

void main() {
  late _FakeMailClient client;

  setUp(() {
    GetIt.I.registerSingleton<Ndk>(_FakeNdk());
    client = _FakeMailClient();
    GetIt.I.registerSingleton<NostrMailService>(_FakeNostrMailService(client));
    final metadata = FakeMetadataService();
    GetIt.I.registerSingleton<MetadataService>(metadata);
    metadata.resolve(Metadata(pubKey: _alice, name: 'Alice'));
    GetIt.I.registerSingleton(AddressBookService());
  });

  tearDown(() => GetIt.I.reset());

  /// Starts the service under an app, the way bootstrap does, and reports
  /// [delivery] to it.
  Future<void> report(WidgetTester tester, UnreachableDelivery delivery) async {
    late BuildContext context;
    await tester.pumpWidget(
      ToastificationWrapper(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    final service = DeliveryAlertService(context: () => context)..start();
    addTearDown(service.dispose);

    client.unreachable.add(delivery);
    // toastification adds the toast after a frame, then animates it in.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Lets the toast close on its own, so no timer outlives the test.
  Future<void> closeToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
  }

  testWidgets('names the recipient with no relay to receive on', (
    tester,
  ) async {
    await report(
      tester,
      UnreachableDelivery(
        emailId: 'email',
        senderPubkey: _sender,
        recipientPubkey: _alice,
      ),
    );

    expect(find.text(_en.emailDeliveryNotDelivered), findsOneWidget);
    expect(
      find.text(_en.composeRecipientsUnreachable(1, 'Alice')),
      findsOneWidget,
    );
    await closeToast(tester);
  });

  testWidgets('names a bridge by the addresses it relays to', (tester) async {
    await report(
      tester,
      UnreachableDelivery(
        emailId: 'email',
        senderPubkey: _sender,
        recipientPubkey: _bridge,
        smtpAddresses: ['bob@example.com'],
      ),
    );

    expect(
      find.text(_en.composeRecipientsUnreachable(1, 'bob@example.com')),
      findsOneWidget,
    );
    await closeToast(tester);
  });

  testWidgets('tells the sender their own account has no relay list', (
    tester,
  ) async {
    await report(
      tester,
      UnreachableDelivery(
        emailId: 'email',
        senderPubkey: _sender,
        recipientPubkey: _sender,
      ),
    );

    expect(find.text(_en.composeSenderUnreachable), findsOneWidget);
    await closeToast(tester);
  });
}
