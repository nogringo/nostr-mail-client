import 'dart:convert';

import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/views/compose/widgets/recipient_autocomplete.dart';

import '../../helpers/fake_metadata_service.dart';

const _bobPubkey =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';

final _nip05FindsBob = MockClient(
  (request) async => http.Response(
    jsonEncode({
      'names': {'bob': _bobPubkey},
    }),
    200,
  ),
);

Contact _contact(String name, String email) => Contact(
  displayName: name,
  mailAddress: MailAddress(name, email),
  source: ContactSource.emailHistory,
);

Future<void> _pumpAutocomplete(
  WidgetTester tester, {
  void Function(Contact contact)? onContactSelected,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: RecipientAutocomplete(
          textController: TextEditingController(),
          hintText: 'To',
          excludeIds: const {},
          onContactSelected: onContactSelected ?? (_) {},
          onManualInput: (_) async => false,
          onSubmitted: (_) {},
        ),
      ),
    ),
  );
}

Future<void> _lookUpBob(WidgetTester tester) => http.runWithClient(() async {
  await _pumpAutocomplete(tester);
  await tester.enterText(find.byType(TextField), 'bob@example.com');
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump();
}, () => _nip05FindsBob);

void main() {
  late Ndk ndk;
  late FakeMetadataService metadataService;
  late ContactsService contactsService;

  setUp(() {
    Get.testMode = true;
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(useIsolate: false),
        bootstrapRelays: const [],
        logLevel: LogLevel.off,
      ),
    );
    Get.put<Ndk>(ndk);
    Get.put(StorageService());
    Get.put(NostrMailService());
    metadataService = FakeMetadataService();
    Get.put<MetadataService>(metadataService);
    contactsService = Get.put(ContactsService());
  });

  tearDown(() async {
    Get.reset();
    await ndk.destroy();
  });

  testWidgets('suggests a contact on the keystroke that matches it', (
    tester,
  ) async {
    contactsService.contacts.value = [
      _contact('Alice Martin', 'alice@example.com'),
    ];
    await _pumpAutocomplete(tester);

    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();

    expect(find.text('Alice Martin'), findsOneWidget);
  });

  testWidgets('suggests contacts that finish loading after the typing', (
    tester,
  ) async {
    await _pumpAutocomplete(tester);
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();
    expect(find.text('Alice Martin'), findsNothing);

    contactsService.contacts.value = [
      _contact('Alice Martin', 'alice@example.com'),
    ];
    await tester.pump();

    expect(find.text('Alice Martin'), findsOneWidget);
  });

  testWidgets('keeps the highlighted contact when the contacts reload', (
    tester,
  ) async {
    final alice = _contact('Alice Martin', 'alice@example.com');
    final natalia = _contact('Natalia Ruiz', 'natalia@example.com');
    contactsService.contacts.value = [alice, natalia];
    Contact? selected;
    await _pumpAutocomplete(
      tester,
      onContactSelected: (contact) => selected = contact,
    );
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);

    // An exact match now ranks above both.
    contactsService.contacts.value = [
      _contact('Ali', 'ali@example.com'),
      alice,
      natalia,
    ];
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(selected, natalia);
  });

  testWidgets('a dismissed list stays closed when the contacts reload', (
    tester,
  ) async {
    final alice = _contact('Alice Martin', 'alice@example.com');
    contactsService.contacts.value = [alice];
    await _pumpAutocomplete(tester);
    await tester.enterText(find.byType(TextField), 'ali');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    contactsService.contacts.value = [alice];
    await tester.pump();

    expect(find.text('Alice Martin'), findsNothing);
  });

  testWidgets('names a NIP-05 match from the cached profile', (tester) async {
    await ndk.config.cache.saveEvent(
      Metadata(pubKey: _bobPubkey, name: 'Bob Stone').toEvent(),
    );

    await _lookUpBob(tester);

    expect(find.text('Bob Stone'), findsOneWidget);
    expect(find.text('Resolving NIP-05...'), findsNothing);
  });

  testWidgets('names an uncached NIP-05 match once its profile loads', (
    tester,
  ) async {
    await _lookUpBob(tester);
    expect(find.text('bob'), findsOneWidget);

    metadataService.resolve(Metadata(pubKey: _bobPubkey, name: 'Bob Stone'));
    await tester.pump();

    expect(find.text('Bob Stone'), findsOneWidget);
  });

  testWidgets('suggests a looked-up profile by its name afterwards', (
    tester,
  ) async {
    await _lookUpBob(tester);
    metadataService.resolve(Metadata(pubKey: _bobPubkey, name: 'Bob Stone'));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Bob St');
    await tester.pump();

    expect(find.text('Bob Stone'), findsOneWidget);
  });
}
