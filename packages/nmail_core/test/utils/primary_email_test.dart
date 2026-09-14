import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/primary_email.dart';
import 'package:nostr_mail/nostr_mail.dart' show PrivateSettings;

void main() {
  const npub = 'npub1test';

  test('prefers the first custom identity', () {
    final settings = PrivateSettings(
      bridges: const ['bridge.example'],
      identities: [
        MailAddress('Alice', 'alice@bridge.example'),
        MailAddress('Bob', 'bob@bridge.example'),
      ],
    );

    expect(
      primaryEmailAddress(npub: npub, settings: settings),
      'alice@bridge.example',
    );
  });

  test('falls back to the npub on the first configured bridge', () {
    final settings = PrivateSettings(
      bridges: const ['first.example', 'second.example'],
      identities: const [],
    );

    expect(
      primaryEmailAddress(npub: npub, settings: settings),
      '$npub@first.example',
    );
  });

  test('falls back to the recommended bridge without settings', () {
    expect(primaryEmailAddress(npub: npub), '$npub@uid.ovh');
  });
}
