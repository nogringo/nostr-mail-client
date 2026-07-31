import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';

enum PushRegistrationAction { register, disable }

/// What the push server did with a request, from the client's point of view.
/// Only [unreachable] is worth retrying: [refused] means the server understood
/// and said no, and the same bytes would fail again.
enum PushDelivery { acked, refused, unreachable }

sealed class PushTransport {
  const PushTransport();

  String get type;

  /// Where the push server delivers. Identifies the subscription with [type].
  String get destination;

  Map<String, dynamic> toJson();

  const factory PushTransport.fcm({required String token}) = FcmPushTransport;

  const factory PushTransport.unifiedPush({
    required String endpoint,
    String? p256dh,
    String? auth,
    String? instance,
  }) = UnifiedPushTransport;

  static PushTransport? fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'fcm':
        final token = json['token'];
        return token is String && token.isNotEmpty
            ? FcmPushTransport(token: token)
            : null;
      case 'unifiedpush':
        final endpoint = json['endpoint'];
        return endpoint is String && endpoint.isNotEmpty
            ? UnifiedPushTransport(
                endpoint: endpoint,
                p256dh: json['p256dh'] as String?,
                auth: json['auth'] as String?,
                instance: json['instance'] as String?,
              )
            : null;
    }
    return null;
  }
}

class FcmPushTransport extends PushTransport {
  const FcmPushTransport({required this.token});

  final String token;

  @override
  String get type => 'fcm';

  @override
  String get destination => token;

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
  String get destination => endpoint;

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
typedef PushLanguageProvider = String Function();
typedef PushTransportPermissionRequester = Future<bool> Function();
typedef PushTransportPreparer = Future<void> Function();

class PushRegistrationService extends GetxService {
  PushRegistrationService({
    Ndk? ndk,
    http.Client? httpClient,
    String endpoint = defaultEndpoint,
    PushAccountProvider? accountProvider,
    PushLanguageProvider? languageProvider,
  }) : _httpClient = httpClient ?? http.Client(),
       _ownsHttpClient = httpClient == null {
    _ndk = ndk;
    _endpoint = endpoint;
    _accountProvider = accountProvider;
    _languageProvider = languageProvider ?? (() => 'en');
  }

  static const officialEndpoint = 'https://api.nmail.li/push/subscriptions';
  static const _configuredEndpoint = String.fromEnvironment(
    'NMAIL_PUSH_ENDPOINT',
  );
  static const defaultEndpoint = _configuredEndpoint == ''
      ? officialEndpoint
      : _configuredEndpoint;
  static const _nip98Kind = 27235;

  /// A subscription for an account the user is leaving or removing has to be
  /// dropped before the account goes away, so no step of that flow may hang on
  /// an unreachable relay, bunker or push server.
  static const _timeout = Duration(seconds: 20);

  late final Ndk? _ndk;
  final http.Client _httpClient;
  final bool _ownsHttpClient;
  late final String _endpoint;
  late final PushAccountProvider? _accountProvider;
  late final PushLanguageProvider _languageProvider;
  PushTransportPermissionRequester? _requestTransportPermission;
  PushTransportPreparer? _prepareTransport;

  PushTransport? _currentTransport;

  PushTransport? get currentTransport => _currentTransport;

  String get languageTag => normalizeLanguageTag(_languageProvider());

  void configureTransportLifecycle({
    PushTransportPermissionRequester? requestPermission,
    PushTransportPreparer? prepareTransport,
  }) {
    _requestTransportPermission = requestPermission;
    _prepareTransport = prepareTransport;
  }

  Future<bool> requestTransportPermission() async {
    final request = _requestTransportPermission;
    if (request == null) return true;
    return request();
  }

  Future<void> prepareCurrentTransport() async {
    final prepare = _prepareTransport;
    if (prepare == null) return;
    await prepare();
  }

  void setCurrentTransport(PushTransport transport) {
    _currentTransport = transport;
  }

  /// Subscribes [account] (the logged one by default) to [transport], with a
  /// NIP-98 authenticated request.
  Future<bool> register(PushTransport transport, {Account? account}) async {
    _currentTransport = transport;
    if (_endpoint.isEmpty) return false;

    final target = account ?? _defaultAccount();
    if (target == null || !target.signer.canSign()) return false;

    final body = jsonEncode(
      buildBody(
        PushRegistrationAction.register,
        transport,
        language: _languageProvider(),
      ),
    );

    final unsigned = Nip01Event(
      pubKey: target.pubkey,
      kind: _nip98Kind,
      tags: [
        ['u', _endpoint],
        ['method', 'POST'],
        ['payload', sha256Hex(utf8.encode(body))],
      ],
      content: '',
      createdAt: Nip01Event.secondsSinceEpoch(),
    );

    final String auth;
    try {
      final signed = await target.signer.sign(unsigned).timeout(_timeout);
      auth = base64Encode(
        utf8.encode(jsonEncode(Nip01EventModel.fromEntity(signed).toJson())),
      );
    } catch (_) {
      return false;
    }

    return await _post(body, auth: auth) == PushDelivery.acked;
  }

  /// Removes the subscription of [pubkey] on [transport], or every subscription
  /// on it when [pubkey] is null. Unauthenticated, so it needs neither the
  /// account nor its key and can be replayed once both are gone.
  Future<PushDelivery> disable(PushTransport transport, {String? pubkey}) {
    return _post(
      jsonEncode(
        buildBody(PushRegistrationAction.disable, transport, pubkey: pubkey),
      ),
    );
  }

  static Map<String, dynamic> buildBody(
    PushRegistrationAction action,
    PushTransport transport, {
    String? language,
    String? pubkey,
  }) {
    return {
      'action': action.name,
      if (action == PushRegistrationAction.register)
        'language': normalizeLanguageTag(language),
      if (action == PushRegistrationAction.disable &&
          pubkey != null &&
          pubkey.isNotEmpty)
        'pubkey': pubkey,
      'transport': transport.toJson(),
    };
  }

  static String normalizeLanguageTag(String? language) {
    final value = language?.trim().replaceAll('_', '-') ?? '';
    return value.isEmpty ? 'en' : value;
  }

  static String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

  Future<PushDelivery> _post(String body, {String? auth}) async {
    if (_endpoint.isEmpty) return PushDelivery.refused;

    try {
      final response = await _httpClient
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              if (auth != null) 'Authorization': 'Nostr $auth',
            },
            body: utf8.encode(body),
          )
          .timeout(_timeout);

      final status = response.statusCode;
      if (status >= 200 && status < 300) return PushDelivery.acked;
      if (status >= 400 && status < 500) return PushDelivery.refused;
      return PushDelivery.unreachable;
    } catch (_) {
      return PushDelivery.unreachable;
    }
  }

  Account? _defaultAccount() {
    final provider = _accountProvider;
    if (provider != null) return provider();
    return _findNdk().accounts.getLoggedAccount();
  }

  Ndk _findNdk() => _ndk ?? Get.find<Ndk>();

  @override
  void onClose() {
    if (_ownsHttpClient) _httpClient.close();
    super.onClose();
  }
}
