import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:nmail_core/services/storage_service.dart';

/// Whether a domain receives email, read from its MX records over
/// DNS-over-HTTPS. A null MX (RFC 7505) counts as no.
///
/// Positive and negative answers are both persisted for [maxAge]. A failed
/// lookup is not an answer: it is never stored and reads as true, so the user
/// keeps the choice.
class MailDomainService extends ChangeNotifier {
  MailDomainService({
    required this._dohServer,
    StorageService? storage,
    http.Client? client,
    DateTime Function()? now,
  }) : _storage = storage ?? GetIt.I<StorageService>(),
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

  final Map<String, bool?> _answers = {};

  /// Null until known, then notifies. The first call for a domain looks it up.
  bool? acceptsMail(String domain) {
    final key = domain.toLowerCase();
    if (_answers.containsKey(key)) return _answers[key];

    _answers[key] = null;
    _load(key);
    return null;
  }

  Future<void> _load(String domain) async {
    final storageKey = '$_keyPrefix$domain';
    final stored = await _storage.getSetting<Map>(storageKey);
    if (stored != null) {
      _answer(domain, stored['acceptsMail'] as bool);
      final checkedAt = DateTime.fromMillisecondsSinceEpoch(
        stored['checkedAt'] as int,
      );
      if (_now().difference(checkedAt) < maxAge) return;
    }

    final bool accepts;
    try {
      accepts = await _queryMx(domain);
    } catch (_) {
      _answer(domain, _answers[domain] ?? true);
      return;
    }
    _answer(domain, accepts);
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

  void _answer(String domain, bool accepts) {
    if (_answers[domain] == accepts) return;
    _answers[domain] = accepts;
    notifyListeners();
  }

  bool _isNullMx(String data) => data.trim().split(RegExp(r'\s+')).last == '.';
}
