// Renders the IzzyOnDroid screenshots into fastlane/, from
// screenshots/seed-data/en.json and a relay that lives in the test:
// flutter test tool/screenshots_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show ImageByteFormat;

import 'package:blossom_cache/blossom_cache.dart';
import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:blossom_upload_queue_shim_for_ndk/sembast_store.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:enough_mail_plus/enough_mail.dart' hide Mailbox;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderRepaintBoundary, debugDisableShadows;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:idb_shim/idb_client_memory.dart';
import 'package:ndk/entities.dart' show Nip65, ReadWriteMarker, UserRelayList;
import 'package:ndk/ndk.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:nmail_core/app/bootstrap.dart';
import 'package:nmail_core/app/config/distribution_config.dart';
import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/services/account_local_data_service.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/app_update_service.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/mail_domain_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/services/theme_service.dart';
import 'package:nmail_core/views/compose/widgets/scrollable_content_view.dart';
import 'package:nostr_mail/nostr_mail.dart' as mail;
import 'package:sembast/sembast_memory.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

// Fastlane screenshots are at most twice as tall as wide.
const android = Size(412, 824);
const store = 'fastlane/metadata/android/en-US/images/phoneScreenshots';
const seedDir = '../../screenshots/seed-data';

void main() {
  final boundary = GlobalKey();
  final relay = _Relay();
  late final Map<String, dynamic> seed;
  late final Uint8List attachment;

  setUpAll(() async {
    await _loadFonts();
    HttpOverrides.global = _LoopbackOnly();
    // ignore: invalid_use_of_visible_for_testing_member
    FlutterSecureStorage.setMockInitialValues({});
    seed =
        jsonDecode(await File('$seedDir/en.json').readAsString())
            as Map<String, dynamic>;
    attachment = await File('$seedDir/attachment.pdf').readAsBytes();
    await relay.start();
  });

  tearDownAll(() => relay.stop());

  Future<void> capture(WidgetTester tester, String name) async {
    await settle(tester);
    final render = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundary),
    );
    await tester.runAsync(() async {
      final image = await render.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ImageByteFormat.png);
      final file = File('$store/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png!.buffer.asUint8List());
    });
  }

  testWidgets('store screenshots', (tester) async {
    tester.view
      ..physicalSize = android
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // flutter_test draws shadows as solid black outlines.
    debugDisableShadows = false;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (_) async => false,
    );

    final accounts = await tester.runAsync(
      () => _publishSeed(relay, seed, attachment),
    );
    await tester.runAsync(() => _startApp(relay, accounts!.primary));
    await tester.pumpWidget(
      RepaintBoundary(key: boundary, child: const MainApp()),
    );
    await tester.runAsync(() async {
      await _login(accounts!.primary);
      await _saveContacts(seed, accounts);
    });
    final client = GetIt.I<NostrMailService>().client;
    final inbox = (seed['inbox'] as List).cast<Map>();
    await until(
      tester,
      () async =>
          (await client.getSummaries(
            folder: Mailbox.requests.folderParam,
          )).items.length ==
          inbox.length,
    );
    await tester.runAsync(() async {
      await GetIt.I<InboxController>().acceptAllRequests();
      final read = {
        for (final email in inbox)
          if (email['isUnread'] != true) email['subject'],
      };
      for (final email in await client.getInboxEmails()) {
        if (read.contains(email.subject)) await client.markAsRead(email.id);
      }
      // The profiles a returning user already holds in memory.
      for (final account in accounts!.senders.values) {
        await GetIt.I<MetadataService>().load(account.pubkey);
      }
    });
    await until(tester, () async => !GetIt.I<InboxController>().isSyncing);
    await capture(tester, '1');

    await tester.tap(find.text(inbox.first['subject'] as String));
    await capture(tester, '2');

    AppRouter.router.go(AppRoutes.compose);
    await settle(tester);
    final compose = tester
        .widget<ScrollableContentView>(find.byType(ScrollableContentView))
        .controller;
    final draft = seed['composeDraft'] as Map<String, dynamic>;
    for (final to in (draft['to'] as List).cast<Map>()) {
      compose.addRecipientFromContact(
        Contact(
          pubkey: accounts!.senders[to['key']]?.pubkey,
          displayName: to['displayName'] as String,
          mailAddress: to['email'] == null
              ? null
              : MailAddress(to['displayName'] as String, to['email'] as String),
          source: ContactSource.addressBook,
        ),
      );
    }
    compose.subjectController.text = draft['subject'] as String;
    compose.quillController.document.insert(0, draft['body'] as String);
    await capture(tester, '3');

    AppRouter.router.go(AppRoutes.contacts);
    await capture(tester, '4');

    AppRouter.router.go(AppRoutes.profile);
    await capture(tester, '5');

    AppRouter.router.go(AppRoutes.inbox);
    await settle(tester);
    GetIt.I<SettingsController>().themeMode.value = ThemeMode.dark;
    await capture(tester, '6');

    await GetIt.I.reset();
    debugDisableShadows = true;
  });
}

Future<void> until(WidgetTester tester, Future<bool> Function() done) async {
  for (var i = 0; i < 30; i++) {
    if (await tester.runAsync(done) ?? false) return;
    await settle(tester);
  }
  throw TimeoutException('The seed never reached the app');
}

/// Pumps frames while the relay, drift and the signer answer in real time.
Future<void> settle(WidgetTester tester, {int seconds = 1}) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  // Android draws its text with Roboto, which the SDK ships for Material.
  final fonts = Directory(
    '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts',
  );
  final roboto = FontLoader('Roboto');
  for (final file in fonts.listSync().whereType<File>()) {
    if (RegExp(r'/Roboto-[A-Za-z]+\.ttf$').hasMatch(file.path)) {
      roboto.addFont(
        file.readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
    }
  }
  await roboto.load();
}

class _Account {
  final String privateKey;
  final String pubkey;

  _Account(this.privateKey)
    : pubkey = Bip340EventSignerFactory().derivePublicKey(privateKey);

  /// The same key on every run, so the avatar colours it picks stay put.
  factory _Account.named(String name) => _Account(
    sha256.convert(utf8.encode('nmail-screenshots:$name')).toString(),
  );

  EventSigner get signer =>
      Bip340EventSigner(privateKey: privateKey, publicKey: pubkey);
}

typedef _Accounts = ({_Account primary, Map<String, _Account> senders});

int _now() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

/// What the screenshot account and its correspondents publish before the app
/// starts: profiles, relay lists and the inbox gift wraps.
Future<_Accounts> _publishSeed(
  _Relay relay,
  Map<String, dynamic> seed,
  Uint8List attachment,
) async {
  final primary = _Account.named('primary');
  final senders = {
    'bridge': _Account.named('bridge'),
    for (final contact in (seed['contacts'] as List).cast<Map>())
      if (contact['key'] case final String key) key: _Account.named(key),
  };

  final runtime = await _SenderRuntime.create(relay.url);
  Future<void> publish(_Account account, Nip01Event event) async {
    final signed = await account.signer.sign(event);
    await runtime.ndk.broadcast
        .broadcast(nostrEvent: signed, specificRelays: [relay.url])
        .broadcastDoneFuture;
  }

  Future<void> profile(_Account account, Metadata metadata) async {
    await publish(account, metadata.toEvent());
    await publish(
      account,
      Nip65(
        pubKey: account.pubkey,
        relays: {relay.url: ReadWriteMarker.readWrite},
        createdAt: _now(),
      ).toEvent(),
    );
  }

  final me = seed['profile'] as Map<String, dynamic>;
  await profile(
    primary,
    Metadata(
      pubKey: primary.pubkey,
      name: me['username'] as String,
      displayName: me['displayName'] as String,
      about: me['about'] as String,
      updatedAt: _now(),
    ),
  );
  await publish(
    primary,
    Nip01Event(
      pubKey: primary.pubkey,
      kind: dmRelayListKind,
      tags: [
        ['relay', relay.url],
      ],
      content: '',
      createdAt: _now(),
    ),
  );
  await profile(
    senders['bridge']!,
    Metadata(
      pubKey: senders['bridge']!.pubkey,
      name: 'nmail-bridge',
      displayName: 'Nmail Bridge',
      updatedAt: _now(),
    ),
  );
  for (final contact in (seed['contacts'] as List).cast<Map>()) {
    final account = senders[contact['key']];
    if (account == null) continue;
    await profile(
      account,
      Metadata(
        pubKey: account.pubkey,
        name: contact['username'] as String?,
        displayName: contact['displayName'] as String,
        about: contact['about'] as String?,
        updatedAt: _now(),
      ),
    );
  }

  final recipient = mail.NostrRecipient.fromPubkey(primary.pubkey);
  final inbox = (seed['inbox'] as List).cast<Map<String, dynamic>>();
  for (final (index, email) in inbox.indexed) {
    final sender = senders[email['senderKey']]!;
    final fromEmail = email['fromEmail'] as String?;
    runtime.ndk.accounts.loginPrivateKey(
      pubkey: sender.pubkey,
      privkey: sender.privateKey,
    );
    await runtime.client.sendMime(
      _message(
        email,
        from: MailAddress(
          email['from'] as String,
          fromEmail ?? '${Nip19.encodePubKey(sender.pubkey)}@nostr',
        ),
        to: recipient.mailAddress,
        date: _date(email['relativeDate'] as String?, index),
        attachment: attachment,
      ),
      to: [recipient],
      keepCopy: false,
      mailFrom: fromEmail,
    );
    runtime.ndk.accounts.logout();
  }
  await runtime.dispose();
  return (primary: primary, senders: senders);
}

MimeMessage _message(
  Map<String, dynamic> email, {
  required MailAddress from,
  required MailAddress to,
  required DateTime date,
  required Uint8List attachment,
}) {
  final html = email['bodyHtml'] as String?;
  final attachments = (email['attachments'] as List? ?? const []).cast<Map>();
  // With attachments the root has to be multipart/mixed, or clients hide them.
  final MessageBuilder builder;
  final PartBuilder body;
  if (attachments.isNotEmpty) {
    builder = MessageBuilder.prepareMultipartMixedMessage();
    body = html == null
        ? builder
        : builder.addPart(mediaSubtype: MediaSubtype.multipartAlternative);
  } else {
    builder = MessageBuilder.prepareMultipartAlternativeMessage();
    body = builder;
  }
  builder
    ..from = [from]
    ..to = [to]
    ..subject = email['subject'] as String
    ..date = date;
  body.addTextPlain((email['body'] as List).join('\n\n'));
  if (html != null) {
    body.addTextHtml(html, transferEncoding: TransferEncoding.base64);
  }
  for (final file in attachments) {
    builder.addBinary(
      attachment,
      MediaType.fromText(file['mimeType'] as String),
      filename: file['fileName'] as String,
    );
  }
  return builder.buildMimeMessage();
}

/// Reads the English labels of the seed data: "Today", "Yesterday", a weekday
/// ("Mon") or a date ("Jul 12").
DateTime _date(String? label, int index) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final time = Duration(hours: 16 - index * 2, minutes: 45 - index * 10);
  const weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  const months = [
    'jan', 'feb', 'mar', 'apr', 'may', 'jun', //
    'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
  ];
  final words = (label ?? '').toLowerCase().split(' ');
  switch (words) {
    case ['today']:
      return now.subtract(Duration(minutes: 25 + index * 11));
    case ['yesterday']:
      return today.subtract(const Duration(days: 1)).add(time);
    case [final day] when weekdays.contains(day):
      var delta = today.weekday - (weekdays.indexOf(day) + 1);
      if (delta <= 0) delta += DateTime.daysPerWeek;
      return today.subtract(Duration(days: delta)).add(time);
    case [final month, final day] when months.contains(month):
      final date = DateTime(
        now.year,
        months.indexOf(month) + 1,
        int.parse(day),
      );
      final year = date.isAfter(today) ? now.year - 1 : now.year;
      return DateTime(year, date.month, date.day).add(time);
  }
  return now.subtract(Duration(days: index));
}

/// One nostr_mail client that sends as each correspondent in turn.
class _SenderRuntime {
  final Ndk ndk;
  final mail.NostrMailDatabase database;
  final SyncEngine syncEngine;
  final mail.NostrMailClient client;

  _SenderRuntime._(this.ndk, this.database, this.syncEngine, this.client);

  static Future<_SenderRuntime> create(String relay) async {
    final ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(),
        bootstrapRelays: [relay],
        logLevel: LogLevel.off,
      ),
    );
    final db = await newDatabaseFactoryMemory().openDatabase('sender');
    final database = mail.NostrMailDatabase(NativeDatabase.memory());
    final syncEngine = SyncEngine(ndk, store: SembastSyncStore(db));
    final client = await mail.NostrMailClient.create(
      ndk: ndk,
      database: database,
      db: db,
      blossomCache: await IdbBlossomCache.open(factory: newIdbFactoryMemory()),
      syncEngine: syncEngine,
      defaultDmRelays: [relay],
    );
    return _SenderRuntime._(ndk, database, syncEngine, client);
  }

  Future<void> dispose() async {
    await client.dispose();
    await database.close();
    await syncEngine.dispose();
    await ndk.destroy();
  }
}

/// The singletons of runNmailApp, kept in memory and on the test relay.
Future<void> _startApp(_Relay relay, _Account primary) async {
  GetIt.I.registerSingleton(
    const DistributionConfig(distribution: Distribution.foss),
  );
  final storage = StorageService()
    ..db = await newDatabaseFactoryMemory().openDatabase('nmail');
  await storage.saveSetting('has_seen_onboarding', true);
  GetIt.I.registerSingleton(storage);

  final ndk = Ndk(
    NdkConfig(
      eventVerifier: Bip340EventVerifier(),
      eventSignerFactory: NdkEventSignerFactory(),
      cache: MemCacheManager(),
      bootstrapRelays: [relay.url],
      logLevel: LogLevel.off,
    ),
  );
  GetIt.I.registerSingleton(ndk);
  GetIt.I.registerSingleton(NdkFlutter(ndk: ndk));
  GetIt.I.registerSingleton(DeviceConnectivityService(connectivity: _Online()));
  GetIt.I.registerSingleton(MetadataService());
  GetIt.I.registerSingleton(
    MailDomainService(
      dohServer: () => GetIt.I<SettingsController>().dohServer.value,
    ),
  );

  final blossomCache = await IdbBlossomCache.open(
    factory: newIdbFactoryMemory(),
  );
  GetIt.I.registerSingleton<BlossomCache>(blossomCache);
  GetIt.I.registerSingleton(
    OfflineBroadcast.withNdk(ndk, db: storage.db)..start(),
  );
  GetIt.I.registerSingleton(
    OfflineBlossomUpload.withNdk(
      ndk,
      cache: blossomCache,
      store: SembastUploadQueueStore(storage.db),
    )..start(),
  );
  GetIt.I.registerSingleton(
    SyncEngine(ndk, store: SembastSyncStore(storage.db)),
  );
  GetIt.I.registerSingleton(mail.NostrMailDatabase(NativeDatabase.memory()));

  GetIt.I.registerSingleton(AccountLocalDataService());
  GetIt.I.registerSingleton(PushSubscriptionService());
  GetIt.I.registerSingleton(await NostrMailService().init());
  GetIt.I.registerSingleton(await AuthController().init());
  GetIt.I.registerSingleton(ThemeService());
  GetIt.I.registerSingleton(await SettingsController().init());
  GetIt.I.registerSingleton(NotificationService());
  GetIt.I.registerSingleton(PushRegistrationService());
  GetIt.I.registerSingleton(AppUpdateService());
  GetIt.I.registerSingleton(AddressBookService()..start());
  GetIt.I.registerLazySingleton(ContactsService.new);
  GetIt.I.registerSingleton(MailboxesController());

  // The relay list the login looks for, as a returning user has it.
  await ndk.config.cache.saveUserRelayList(
    UserRelayList(
      pubKey: primary.pubkey,
      relays: {relay.url: ReadWriteMarker.readWrite},
      createdAt: _now(),
      refreshedTimestamp: _now(),
    ),
  );
}

Future<void> _login(_Account primary) async {
  GetIt.I<Ndk>().accounts.loginPrivateKey(
    pubkey: primary.pubkey,
    privkey: primary.privateKey,
  );
  await GetIt.I<AuthController>().onLoggedIn();
  AppRouter.router.go(AppRoutes.inbox);
}

Future<void> _saveContacts(
  Map<String, dynamic> seed,
  _Accounts accounts,
) async {
  for (final contact in (seed['contacts'] as List).cast<Map>()) {
    final account = accounts.senders[contact['key']];
    await GetIt.I<AddressBookService>().saveContact(
      AddressBookContactForm(
        displayName: contact['displayName'] as String,
        emails: List<String>.from(contact['emails'] as List),
        phones: List<String>.from(contact['phones'] as List),
        nostrPubkeys: [?account?.pubkey],
      ),
    );
  }
}

class _Online implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

/// flutter_test answers every request with 400; this lets the test relay
/// through and keeps every other host unreachable.
class _LoopbackOnly extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..connectionFactory = (uri, proxyHost, proxyPort) {
          if (uri.host != InternetAddress.loopbackIPv4.address) {
            return Future.error(SocketException('Offline: ${uri.host}'));
          }
          return Socket.startConnect(uri.host, uri.port);
        };
}

/// A NIP-01 relay in memory: it keeps what it is sent and answers REQs from it.
class _Relay {
  late final HttpServer _server;
  final _events = <Map<String, dynamic>>[];
  final _subscriptions = <WebSocket, Map<String, List<Map>>>{};

  String get url => 'ws://127.0.0.1:${_server.port}';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((request) async {
      if (!WebSocketTransformer.isUpgradeRequest(request)) {
        // A NIP-11 document with nothing to say.
        request.response.headers.contentType = ContentType.json;
        request.response.write('{}');
        await request.response.close();
        return;
      }
      final socket = await WebSocketTransformer.upgrade(request);
      _subscriptions[socket] = {};
      socket.listen(
        (data) => _handle(socket, jsonDecode(data as String) as List),
        onDone: () => _subscriptions.remove(socket),
      );
    });
  }

  Future<void> stop() => _server.close(force: true);

  void _handle(WebSocket socket, List message) {
    switch (message) {
      case ['REQ', final String id, ...final filters]:
        _subscriptions[socket]![id] = filters.cast<Map>();
        for (final event in _events) {
          if (filters.cast<Map>().any((filter) => _matches(filter, event))) {
            socket.add(jsonEncode(['EVENT', id, event]));
          }
        }
        socket.add(jsonEncode(['EOSE', id]));
      case ['CLOSE', final String id]:
        _subscriptions[socket]!.remove(id);
      case ['EVENT', final Map<String, dynamic> event]:
        _store(event);
        socket.add(jsonEncode(['OK', event['id'], true, '']));
        for (final MapEntry(key: client, value: subscriptions)
            in _subscriptions.entries) {
          for (final MapEntry(key: id, value: filters)
              in subscriptions.entries) {
            if (filters.any((filter) => _matches(filter, event))) {
              client.add(jsonEncode(['EVENT', id, event]));
            }
          }
        }
    }
  }

  void _store(Map<String, dynamic> event) {
    final kind = event['kind'] as int;
    String? d() => (event['tags'] as List)
        .cast<List>()
        .where((tag) => tag.length > 1 && tag[0] == 'd')
        .map((tag) => tag[1] as String)
        .firstOrNull;
    final replaceable =
        kind == 0 || kind == 3 || (kind >= 10000 && kind < 20000);
    final addressable = kind >= 30000 && kind < 40000;
    if (replaceable || addressable) {
      _events.removeWhere(
        (other) =>
            other['kind'] == kind &&
            other['pubkey'] == event['pubkey'] &&
            (!addressable ||
                (other['tags'] as List).cast<List>().any(
                  (tag) => tag.length > 1 && tag[0] == 'd' && tag[1] == d(),
                )),
      );
    }
    _events.add(event);
  }

  bool _matches(Map filter, Map<String, dynamic> event) {
    for (final MapEntry(:key, :value) in filter.entries) {
      final ok = switch (key) {
        'ids' => (value as List).contains(event['id']),
        'authors' => (value as List).contains(event['pubkey']),
        'kinds' => (value as List).contains(event['kind']),
        'since' => (event['created_at'] as int) >= (value as int),
        'until' => (event['created_at'] as int) <= (value as int),
        'limit' => true,
        final String tag when tag.startsWith('#') =>
          (event['tags'] as List).cast<List>().any(
            (t) =>
                t.length > 1 &&
                t[0] == tag.substring(1) &&
                (value as List).contains(t[1]),
          ),
        _ => true,
      };
      if (!ok) return false;
    }
    return true;
  }
}
