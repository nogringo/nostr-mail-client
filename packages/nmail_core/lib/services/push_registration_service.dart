import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';

enum PushRegistrationAction { register, disable }

sealed class PushTransport {
  const PushTransport();

  String get type;

  Map<String, dynamic> toJson();

  const factory PushTransport.fcm({required String token}) = FcmPushTransport;

  const factory PushTransport.unifiedPush({
    required String endpoint,
    String? p256dh,
    String? auth,
    String? instance,
  }) = UnifiedPushTransport;
}

class FcmPushTransport extends PushTransport {
  const FcmPushTransport({required this.token});

  final String token;

  @override
  String get type => 'fcm';

  @override
  Map<String, dynamic> toJson() => {'type': type, 'token': token};
}

class UnifiedPushTransport extends PushTransport {
  const UnifiedPushTransport({
    required this.endpoint,
    this.p256dh,
    this.auth,
    this.instance,
  });

  final String endpoint;
  final String? p256dh;
  final String? auth;
  final String? instance;

  @override
  String get type => 'unifiedpush';

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'endpoint': endpoint,
      if (p256dh != null && p256dh!.isNotEmpty) 'p256dh': p256dh,
      if (auth != null && auth!.isNotEmpty) 'auth': auth,
      if (instance != null && instance!.isNotEmpty) 'instance': instance,
    };
  }
}

typedef PushAccountProvider = Account? Function();

class PushRegistrationService extends GetxService {
  PushRegistrationService({
    Ndk? ndk,
    http.Client? httpClient,
    String endpoint = defaultEndpoint,
    PushAccountProvider? accountProvider,
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null {
    _ndk = ndk;
    _endpoint = endpoint;
    _accountProvider = accountProvider;
  }

  static const officialEndpoint = 'https://api.nmail.li/push/subscriptions';
  static const _configuredEndpoint = String.fromEnvironment(
    'NMAIL_PUSH_ENDPOINT',
  );
  static const defaultEndpoint = _configuredEndpoint == ''
      ? officialEndpoint
      : _configuredEndpoint;
  static const _nip98Kind = 27235;

  late final Ndk? _ndk;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  late final String _endpoint;
  late final PushAccountProvider? _accountProvider;

  PushTransport? _currentTransport;

  PushTransport? get currentTransport => _currentTransport;

  void setCurrentTransport(PushTransport transport) {
    _currentTransport = transport;
  }

  Future<bool> registerCurrentTransport() async {
    final transport = _currentTransport;
    if (transport == null) return false;
    return register(transport);
  }

  Future<bool> disableCurrentTransport() async {
    final transport = _currentTransport;
    if (transport == null) return false;
    return disable(transport);
  }

  Future<bool> register(PushTransport transport) {
    _currentTransport = transport;
    return _send(PushRegistrationAction.register, transport);
  }

  Future<bool> disable(PushTransport transport) {
    return _send(PushRegistrationAction.disable, transport);
  }

  static Map<String, dynamic> buildBody(
    PushRegistrationAction action,
    PushTransport transport,
  ) {
    return {'action': action.name, 'transport': transport.toJson()};
  }

  static String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

  Future<bool> _send(
    PushRegistrationAction action,
    PushTransport transport,
  ) async {
    if (_endpoint.isEmpty) {
      return false;
    }

    final account = _accountProvider != null
        ? _accountProvider()
        : _findNdk().accounts.getLoggedAccount();
    if (account == null || !account.signer.canSign()) {
      return false;
    }

    final url = Uri.parse(_endpoint);
    final bodyBytes = utf8.encode(jsonEncode(buildBody(action, transport)));
    final payloadHash = sha256Hex(bodyBytes);

    final unsigned = Nip01Event(
      pubKey: account.pubkey,
      kind: _nip98Kind,
      tags: [
        ['u', url.toString()],
        ['method', 'POST'],
        ['payload', payloadHash],
      ],
      content: '',
      createdAt: Nip01Event.secondsSinceEpoch(),
    );

    try {
      final signed = await account.signer.sign(unsigned);
      final auth = base64Encode(
        utf8.encode(jsonEncode(Nip01EventModel.fromEntity(signed).toJson())),
      );

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Nostr $auth',
        },
        body: bodyBytes,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Ndk _findNdk() => _ndk ?? Get.find<Ndk>();

  @override
  void onClose() {
    if (_ownsHttpClient) _httpClient.close();
    super.onClose();
  }
}
