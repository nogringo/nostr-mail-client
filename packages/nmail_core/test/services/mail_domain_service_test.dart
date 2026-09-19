import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nmail_core/services/mail_domain_service.dart';
import 'package:nmail_core/services/storage_service.dart';

const _server = 'https://doh.example/dns-query';

http.Response _dns(
  int status, [
  List<Map<String, Object>> answers = const [],
]) => http.Response(jsonEncode({'Status': status, 'Answer': answers}), 200);

Map<String, Object> _mx(String data) => {
  'name': 'opensats.org.',
  'type': 15,
  'TTL': 300,
  'data': data,
};

void main() {
  late _MemoryStorage storage;
  late List<Uri> requests;
  late DateTime now;
  late http.Response Function() respond;

  MailDomainService service() => MailDomainService(
    dohServer: () => _server,
    storage: storage,
    now: () => now,
    client: MockClient((request) async {
      requests.add(request.url);
      return respond();
    }),
  );

  Future<bool?> lookup(MailDomainService service, String domain) async {
    final slot = service.acceptsMail(domain);
    await pumpEventQueue();
    return slot.value;
  }

  setUp(() {
    storage = _MemoryStorage();
    requests = [];
    now = DateTime(2026, 9, 18);
    respond = () => _dns(0, [_mx('10 mail.opensats.org.')]);
  });

  test('asks the DoH server for the MX records of the domain', () async {
    expect(await lookup(service(), 'OpenSats.org'), isTrue);
    expect(requests.single.queryParameters, {
      'name': 'opensats.org',
      'type': 'MX',
    });
  });

  test(
    'a domain without MX, or with a null MX, does not accept mail',
    () async {
      respond = () => _dns(0);
      expect(await lookup(service(), 'a.org'), isFalse);
      respond = () => _dns(0, [_mx('0 .')]);
      expect(await lookup(service(), 'b.org'), isFalse);
      respond = () => _dns(3);
      expect(await lookup(service(), 'c.org'), isFalse);
    },
  );

  test('positive and negative answers are persisted', () async {
    await lookup(service(), 'opensats.org');
    respond = () => _dns(3);
    await lookup(service(), 'nowhere.org');

    requests.clear();
    final restarted = service();
    expect(await lookup(restarted, 'opensats.org'), isTrue);
    expect(await lookup(restarted, 'nowhere.org'), isFalse);
    expect(requests, isEmpty);
  });

  test('a stored answer is looked up again once older than maxAge', () async {
    respond = () => _dns(3);
    await lookup(service(), 'opensats.org');

    now = now.add(MailDomainService.maxAge);
    respond = () => _dns(0, [_mx('10 mail.opensats.org.')]);
    requests.clear();
    expect(await lookup(service(), 'opensats.org'), isTrue);
    expect(requests, hasLength(1));
  });

  test('a failed lookup reads as true and is not stored', () async {
    respond = () => http.Response('oops', 503);
    expect(await lookup(service(), 'opensats.org'), isTrue);
    expect(storage.values, isEmpty);

    respond = () => _dns(2);
    expect(await lookup(service(), 'other.org'), isTrue);
    expect(storage.values, isEmpty);
  });

  test('a failed refresh keeps the stored answer', () async {
    respond = () => _dns(3);
    await lookup(service(), 'opensats.org');

    now = now.add(MailDomainService.maxAge);
    respond = () => http.Response('oops', 503);
    expect(await lookup(service(), 'opensats.org'), isFalse);
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
