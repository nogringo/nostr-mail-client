import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nmail_core/services/app_update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Nmail',
      packageName: 'org.nostrmail.app',
      version: '0.16.0',
      buildNumber: '28',
      buildSignature: '',
    );
  });

  AppUpdateService serviceReturning(
    int status, [
    String tag = '',
  ]) => AppUpdateService(
    client: MockClient(
      (_) async => http.Response(
        jsonEncode({
          'tag_name': tag,
          'html_url':
              'https://github.com/nogringo/nostr-mail-client/releases/tag/$tag',
        }),
        status,
      ),
    ),
  );

  test('exposes a newer release', () async {
    final service = serviceReturning(200, 'v0.17.0');
    await service.check();

    expect(service.availableUpdate.value?.version, '0.17.0');
    expect(
      service.availableUpdate.value?.url,
      'https://github.com/nogringo/nostr-mail-client/releases/tag/v0.17.0',
    );
  });

  test('ignores the release already running', () async {
    final service = serviceReturning(200, 'v0.16.0');
    await service.check();

    expect(service.availableUpdate.value, isNull);
  });

  test('keeps the previous state when GitHub fails', () async {
    final service = serviceReturning(200, 'v0.17.0');
    await service.check();

    final failing = serviceReturning(403);
    failing.availableUpdate.value = service.availableUpdate.value;
    await failing.check();

    expect(failing.availableUpdate.value?.version, '0.17.0');
  });
}
