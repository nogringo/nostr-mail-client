import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';
import 'package:nmail_core/services/push_registration_service.dart';

import '../helpers/fake_event_signer.dart';

void main() {
  group('PushRegistrationService body', () {
    test('builds minimal FCM register body', () {
      expect(
        PushRegistrationService.buildBody(
          PushRegistrationAction.register,
          const PushTransport.fcm(token: 'token-1'),
          language: 'fr',
        ),
        {
          'action': 'register',
          'language': 'fr',
          'transport': {'type': 'fcm', 'token': 'token-1'},
        },
      );
    });

    test('builds minimal UnifiedPush register body', () {
      expect(
        PushRegistrationService.buildBody(
          PushRegistrationAction.register,
          const PushTransport.unifiedPush(
            endpoint: 'https://push.example/abc',
            p256dh: 'key',
            auth: 'auth-secret',
            instance: 'nmail',
          ),
          language: 'pt-BR',
        ),
        {
          'action': 'register',
          'language': 'pt-BR',
          'transport': {
            'type': 'unifiedpush',
            'endpoint': 'https://push.example/abc',
            'p256dh': 'key',
            'auth': 'auth-secret',
            'instance': 'nmail',
          },
        },
      );
    });

    test('normalizes empty or underscore language tags', () {
      expect(PushRegistrationService.normalizeLanguageTag(null), 'en');
      expect(PushRegistrationService.normalizeLanguageTag(''), 'en');
      expect(PushRegistrationService.normalizeLanguageTag('pt_BR'), 'pt-BR');
    });

    test('builds minimal FCM disable body', () {
      expect(
        PushRegistrationService.buildBody(
          PushRegistrationAction.disable,
          const PushTransport.fcm(token: 'token-1'),
        ),
        {
          'action': 'disable',
          'transport': {'type': 'fcm', 'token': 'token-1'},
        },
      );
    });

    test('builds minimal UnifiedPush disable body', () {
      expect(
        PushRegistrationService.buildBody(
          PushRegistrationAction.disable,
          const PushTransport.unifiedPush(endpoint: 'https://push.example/abc'),
        ),
        {
          'action': 'disable',
          'transport': {
            'type': 'unifiedpush',
            'endpoint': 'https://push.example/abc',
          },
        },
      );
    });
  });

  group('PushRegistrationService requests', () {
    test('transport lifecycle defaults are silent and permissive', () async {
      final service = PushRegistrationService(endpoint: '');

      expect(await service.requestTransportPermission(), isTrue);
      await service.prepareCurrentTransport();
      expect(service.currentTransport, isNull);
    });

    test('transport lifecycle callbacks are invoked', () async {
      var permissionRequests = 0;
      var prepareCalls = 0;
      final service = PushRegistrationService(endpoint: '');

      service.configureTransportLifecycle(
        requestPermission: () async {
          permissionRequests += 1;
          return false;
        },
        prepareTransport: () async {
          prepareCalls += 1;
          service.setCurrentTransport(
            const PushTransport.fcm(token: 'token-1'),
          );
        },
      );

      expect(await service.requestTransportPermission(), isFalse);
      await service.prepareCurrentTransport();

      expect(permissionRequests, 1);
      expect(prepareCalls, 1);
      expect(
        service.currentTransport,
        const PushTransport.fcm(token: 'token-1'),
      );
    });

    test('signs NIP-98 payload over exact request body bytes', () async {
      final signer = FakeEventSigner();
      final client = _CapturingClient();
      final service = PushRegistrationService(
        endpoint: 'https://push.example/register',
        httpClient: client,
        accountProvider: () => Account(
          type: AccountType.privateKey,
          pubkey: signer.publicKey,
          signer: signer,
        ),
        languageProvider: () => 'fr-FR',
      );

      final ok = await service.register(
        const PushTransport.fcm(token: 'token-1'),
      );

      expect(ok, isTrue);
      expect(client.request?.method, 'POST');
      expect(client.request?.url.toString(), 'https://push.example/register');
      expect(client.request?.headers['Content-Type'], 'application/json');
      expect(client.request?.headers['Authorization'], startsWith('Nostr '));

      final event = signer.lastEvent!;
      expect(event.kind, 27235);
      expect(event.content, isEmpty);
      expect(event.getFirstTag('u'), 'https://push.example/register');
      expect(event.getFirstTag('method'), 'POST');
      expect(
        event.getFirstTag('payload'),
        PushRegistrationService.sha256Hex(client.bodyBytes),
      );

      expect(jsonDecode(utf8.decode(client.bodyBytes)), {
        'action': 'register',
        'language': 'fr-FR',
        'transport': {'type': 'fcm', 'token': 'token-1'},
      });
    });

    test('no-ops when endpoint is empty', () async {
      final signer = FakeEventSigner();
      final client = _CapturingClient();
      final service = PushRegistrationService(
        endpoint: '',
        httpClient: client,
        accountProvider: () => Account(
          type: AccountType.privateKey,
          pubkey: signer.publicKey,
          signer: signer,
        ),
      );

      final ok = await service.register(
        const PushTransport.fcm(token: 'token-1'),
      );

      expect(ok, isFalse);
      expect(client.request, isNull);
    });

    test('no-ops when no signer is available', () async {
      final client = _CapturingClient();
      final service = PushRegistrationService(
        endpoint: 'https://push.example/register',
        httpClient: client,
        accountProvider: () => null,
      );

      final ok = await service.register(
        const PushTransport.fcm(token: 'token-1'),
      );

      expect(ok, isFalse);
      expect(client.request, isNull);
    });

    test('returns false on non-2xx responses', () async {
      final signer = FakeEventSigner();
      final client = _CapturingClient(statusCode: 500);
      final service = PushRegistrationService(
        endpoint: 'https://push.example/register',
        httpClient: client,
        accountProvider: () => Account(
          type: AccountType.privateKey,
          pubkey: signer.publicKey,
          signer: signer,
        ),
      );

      final ok = await service.register(
        const PushTransport.fcm(token: 'token-1'),
      );

      expect(ok, isFalse);
      expect(client.request, isNotNull);
    });
  });
}

class _CapturingClient extends http.BaseClient {
  _CapturingClient({this.statusCode = 204});

  final int statusCode;
  http.BaseRequest? request;
  List<int> bodyBytes = const [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    bodyBytes = await request.finalize().toBytes();
    return http.StreamedResponse(Stream<List<int>>.value(const []), statusCode);
  }
}
