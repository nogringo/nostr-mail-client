import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';
import 'package:nmail_core/services/pending_push_disables.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Ndk ndk;
  late Database db;
  late String activePubkey;
  late String otherPubkey;
  late _MemoryStorage storage;
  late _CapturingClient client;
  late PushRegistrationService registration;
  late PushSubscriptionService subscriptions;
  late String language;

  setUp(() async {
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(useIsolate: false),
        bootstrapRelays: const [],
        logLevel: LogLevel.off,
      ),
    );

    const factory = Bip340EventSignerFactory();
    final (activePrivkey, active) = factory.generateKeyPair();
    final (otherPrivkey, other) = factory.generateKeyPair();
    activePubkey = active;
    otherPubkey = other;
    ndk.accounts.loginPrivateKey(pubkey: other, privkey: otherPrivkey);
    ndk.accounts.loginPrivateKey(pubkey: active, privkey: activePrivkey);

    db = await databaseFactoryMemory.openDatabase('push_subscriptions.db');
    storage = _MemoryStorage();
    client = _CapturingClient();
    language = 'fr';
    registration = PushRegistrationService(
      ndk: ndk,
      httpClient: client,
      endpoint: 'https://push.example/subscriptions',
      languageProvider: () => language,
    );
    registration.setCurrentTransport(const PushTransport.fcm(token: 'token-1'));
    subscriptions = PushSubscriptionService(
      storage: storage,
      ndk: ndk,
      registration: registration,
      pending: PendingPushDisables(db: db, registration: registration),
    );
  });

  tearDown(() async {
    await ndk.destroy();
    await db.close();
  });

  test(
    'adopts the pre-multi-account flag for the account that wrote it',
    () async {
      storage.values[PushSubscriptionService.preMultiAccountEnabledKey] = true;

      expect(await subscriptions.resolveEnabled(activePubkey), isTrue);
      expect(
        storage.values[PushSubscriptionService.enabledKey(activePubkey)],
        isTrue,
      );
      expect(
        storage.values.containsKey(
          PushSubscriptionService.preMultiAccountEnabledKey,
        ),
        isFalse,
      );
      expect(await subscriptions.isEnabled(otherPubkey), isFalse);
      expect(
        storage.values[PushSubscriptionService.registrationKey(activePubkey)],
        isNotNull,
      );
    },
  );

  test('subscribes and unsubscribes the account being toggled', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);

    expect(client.requests, hasLength(1));
    expect(client.requests.single['action'], 'register');
    expect(client.requests.single['signedBy'], activePubkey);
    expect(client.requests.single['language'], 'fr');
    expect(await subscriptions.hasEnabledAccount(), isTrue);

    await subscriptions.setEnabled(pubkey: activePubkey, value: false);

    expect(client.requests.last['action'], 'disable');
    expect(client.requests.last['pubkey'], activePubkey);
    expect(client.requests.last['signedBy'], isNull);
    expect(await subscriptions.hasEnabledAccount(), isFalse);
  });

  test('a new token re-subscribes every enabled account', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);
    await subscriptions.setEnabled(pubkey: otherPubkey, value: true);
    client.requests.clear();

    registration.setCurrentTransport(const PushTransport.fcm(token: 'token-2'));
    await subscriptions.syncAll();

    expect(client.requests.map((r) => r['signedBy']).toSet(), {
      activePubkey,
      otherPubkey,
    });
    expect(
      client.requests.every((r) => r['transport']['token'] == 'token-2'),
      isTrue,
    );
  });

  test('skips accounts already subscribed with this transport', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);
    client.requests.clear();

    await subscriptions.syncAll();

    expect(client.requests, isEmpty);
  });

  test('a language change re-subscribes', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);
    client.requests.clear();

    language = 'en';
    await subscriptions.syncAll();

    expect(client.requests.single['language'], 'en');
  });

  test('forget unsubscribes and drops the setting', () async {
    await subscriptions.setEnabled(pubkey: otherPubkey, value: true);
    client.requests.clear();

    await subscriptions.forget(otherPubkey);

    expect(client.requests.single['action'], 'disable');
    expect(client.requests.single['pubkey'], otherPubkey);
    expect(
      storage.values.containsKey(
        PushSubscriptionService.enabledKey(otherPubkey),
      ),
      isFalse,
    );
    expect(
      storage.values.containsKey(
        PushSubscriptionService.registrationKey(otherPubkey),
      ),
      isFalse,
    );
  });

  test('forget stays silent for an account that never subscribed', () async {
    await subscriptions.forget(otherPubkey);

    expect(client.requests, isEmpty);
  });

  test('forget drops a subscription adopted from the old flag', () async {
    storage.values[PushSubscriptionService.preMultiAccountEnabledKey] = true;
    await subscriptions.resolveEnabled(activePubkey);

    await subscriptions.forget(activePubkey);

    expect(client.requests.single['action'], 'disable');
    expect(client.requests.single['pubkey'], activePubkey);
    expect(client.requests.single['transport']['token'], 'token-1');
  });

  test('unsubscribes the transport that carried the subscription', () async {
    await subscriptions.setEnabled(pubkey: otherPubkey, value: true);
    registration.setCurrentTransport(const PushTransport.fcm(token: 'token-2'));
    client.requests.clear();

    await subscriptions.forget(otherPubkey);

    expect(client.requests.single['action'], 'disable');
    expect(client.requests.single['transport']['token'], 'token-1');
  });

  test('replays a disable the server never received', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);

    client.statusCode = 503;
    await subscriptions.setEnabled(pubkey: activePubkey, value: false);

    client.statusCode = 204;
    client.requests.clear();
    await subscriptions.syncAll();

    expect(client.requests.single['action'], 'disable');
    expect(client.requests.single['pubkey'], activePubkey);
  });

  test('replays a disable after the account left the device', () async {
    await subscriptions.setEnabled(pubkey: otherPubkey, value: true);

    client.statusCode = 503;
    await subscriptions.forget(otherPubkey);
    ndk.accounts.removeAccount(pubkey: otherPubkey);

    client.statusCode = 204;
    client.requests.clear();
    await subscriptions.flushPendingDisables();

    expect(client.requests.single['action'], 'disable');
    expect(client.requests.single['pubkey'], otherPubkey);
    expect(client.requests.single['signedBy'], isNull);
  });

  test('subscribing again cancels a queued disable', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);

    client.statusCode = 503;
    await subscriptions.setEnabled(pubkey: activePubkey, value: false);

    client.statusCode = 204;
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);
    client.requests.clear();
    await subscriptions.flushPendingDisables();

    expect(client.requests, isEmpty);
  });

  test('a refused disable is not replayed', () async {
    await subscriptions.setEnabled(pubkey: activePubkey, value: true);

    client.statusCode = 400;
    await subscriptions.setEnabled(pubkey: activePubkey, value: false);

    client.statusCode = 204;
    client.requests.clear();
    await subscriptions.flushPendingDisables();

    expect(client.requests, isEmpty);
  });

  test('does nothing without a transport', () async {
    final withoutTransport = PushSubscriptionService(
      storage: storage,
      ndk: ndk,
      registration: PushRegistrationService(
        ndk: ndk,
        httpClient: client,
        endpoint: 'https://push.example/subscriptions',
      ),
      pending: PendingPushDisables(db: db, registration: registration),
    );

    await withoutTransport.setEnabled(pubkey: activePubkey, value: true);

    expect(client.requests, isEmpty);
    expect(
      storage.values[PushSubscriptionService.enabledKey(activePubkey)],
      isTrue,
    );
  });
}

class _MemoryStorage extends StorageService {
  final values = <String, dynamic>{};

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    values[key] = value;
  }

  @override
  Future<T?> getSetting<T>(String key) async => values[key] as T?;

  @override
  Future<void> deleteSetting(String key) async {
    values.remove(key);
  }
}

/// Records the decoded body of each request, with the pubkey that signed its
/// NIP-98 authorization under `signedBy` when there is one.
class _CapturingClient extends http.BaseClient {
  final requests = <Map<String, dynamic>>[];
  int statusCode = 204;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bodyBytes = await request.finalize().toBytes();
    final auth = request.headers['Authorization'];
    final signed = auth == null
        ? null
        : jsonDecode(utf8.decode(base64Decode(auth.split(' ').last)))
              as Map<String, dynamic>;

    requests.add({
      'signedBy': signed?['pubkey'],
      ...jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>,
    });

    return http.StreamedResponse(Stream<List<int>>.value(const []), statusCode);
  }
}
