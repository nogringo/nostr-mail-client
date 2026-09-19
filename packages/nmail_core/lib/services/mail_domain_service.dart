import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:nmail_core/services/storage_service.dart';

/// Whether a domain receives email, read from its MX records over
/// DNS-over-HTTPS. A null MX (RFC 7505) counts as no.
///
/// Positive and negative answers are both persisted for [maxAge]. A failed
/// lookup is not an answer: it is never stored and reads as true, so the user
/// keeps the choice.
class MailDomainService extends GetxService {
  MailDomainService({
    required this._dohServer,
    StorageService? storage,
    http.Client? client,
    DateTime Function()? now,
  }) : _storage = storage ?? Get.find<StorageService>(),
       _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  static const maxAge = Duration(days: 30);
  static const _timeout = Duration(seconds: 5);
  static const _keyPrefix = 'mail_domain:';
  static const _mxType = 15;
  static const _nxDomain = 3;

  final String Function() _dohServer;
  final StorageService _storage;
  final http.Client _client;
  final DateTime Function() _now;

  final Map<String, Rx<bool?>> _cache = {};

  /// Null until known. Read `.value` inside an `Obx` to rebuild on the answer.
  Rx<bool?> acceptsMail(String domain) {
    final key = domain.toLowerCase();
    final existing = _cache[key];
    if (existing != null) return existing;

    final slot = Rx<bool?>(null);
    _cache[key] = slot;
    _load(key, slot);
    return slot;
  }

  Future<void> _load(String domain, Rx<bool?> slot) async {
    final storageKey = '$_keyPrefix$domain';
    final stored = await _storage.getSetting<Map>(storageKey);
    if (stored != null) {
      slot.value = stored['acceptsMail'] as bool;
      final checkedAt = DateTime.fromMillisecondsSinceEpoch(
        stored['checkedAt'] as int,
      );
      if (_now().difference(checkedAt) < maxAge) return;
    }

    final bool accepts;
    try {
      accepts = await _queryMx(domain);
    } catch (_) {
      slot.value ??= true;
      return;
    }
    slot.value = accepts;
    await _storage.saveSetting(storageKey, {
      'acceptsMail': accepts,
      'checkedAt': _now().millisecondsSinceEpoch,
    });
  }

  Future<bool> _queryMx(String domain) async {
    final server = Uri.parse(_dohServer());
    final url = server.replace(
      queryParameters: {
        ...server.queryParameters,
        'name': domain,
        'type': 'MX',
      },
    );
    final response = await _client
        .get(url, headers: {'accept': 'application/dns-json'})
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', url);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = json['Status'];
    if (status == _nxDomain) return false;
    if (status != 0) throw FormatException('DNS status $status');

    final answers = (json['Answer'] as List?) ?? const [];
    return answers.whereType<Map>().any(
      (answer) =>
          answer['type'] == _mxType && !_isNullMx(answer['data'] as String),
    );
  }

  bool _isNullMx(String data) => data.trim().split(RegExp(r'\s+')).last == '.';
}
