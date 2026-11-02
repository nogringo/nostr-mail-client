import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart'
    show NetworkRequiredException, NostrMailClient;

import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/views/compose/widgets/unreachable_recipients_text.dart';

import '../../helpers/fake_metadata_service.dart';

class _FakeNdk implements Ndk {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// No relay answers a lookup, as offline.
class _OfflineMailClient implements NostrMailClient {
  @override
  Future<List<String>> getReadRelays(String pubkey) async =>
      throw NetworkRequiredException('relay-lists', 'no relay reached');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNostrMailService implements NostrMailService {
  @override
  final NostrMailClient client = _OfflineMailClient();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _en = lookupAppLocalizations(const Locale('en'));

const _pubkey =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';

void main() {
  late ComposeController controller;
  late Recipient recipient;

  setUp(() {
    GetIt.I.registerSingleton<Ndk>(_FakeNdk());
    GetIt.I.registerSingleton<NostrMailService>(_FakeNostrMailService());
    final metadata = FakeMetadataService();
    GetIt.I.registerSingleton<MetadataService>(metadata);
    metadata.resolve(Metadata(pubKey: _pubkey, name: 'Bob'));
    GetIt.I.registerSingleton(AddressBookService());
    GetIt.I.registerSingleton(ContactsService());
    controller = ComposeController();
    recipient = Recipient(
      input: Nip19.encodePubKey(_pubkey),
      pubkey: _pubkey,
      type: RecipientType.nostr,
    );
    controller.recipients.add(recipient);
  });

  tearDown(() => GetIt.I.reset());

  Future<ThemeData> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: UnreachableRecipientsText(
            controller: controller,
            recipients: [recipient],
          ),
        ),
      ),
    );
    await tester.pump();
    return Theme.of(tester.element(find.byType(UnreachableRecipientsText)));
  }

  testWidgets('an unchecked recipient of an email that can still go is '
      'named without an error', (tester) async {
    final theme = await pump(tester);

    final text = tester.widget<Text>(
      find.text(_en.composeRecipientsUncheckedQueued(1, 'Bob')),
    );
    expect(text.style?.color, theme.colorScheme.onSurfaceVariant);
  });

  testWidgets('an unchecked recipient of a scheduled email is an error', (
    tester,
  ) async {
    controller.scheduledAt = DateTime(2030);
    final theme = await pump(tester);

    final text = tester.widget<Text>(
      find.text(_en.composeRecipientsUnchecked(1, 'Bob')),
    );
    expect(text.style?.color, theme.colorScheme.error);
    expect(
      find.text(_en.composeRecipientsUncheckedQueued(1, 'Bob')),
      findsNothing,
    );
  });

  testWidgets('scheduling switches the message to an error', (tester) async {
    await pump(tester);

    controller.scheduledAt = DateTime(2030);
    await tester.pump();

    expect(find.text(_en.composeRecipientsUnchecked(1, 'Bob')), findsOneWidget);
  });
}
