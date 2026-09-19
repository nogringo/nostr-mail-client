import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/nip05_mail_address.dart';

void main() {
  test('keeps a name at a domain', () {
    expect(nip05MailAddress('Support@OpenSats.org'), 'support@opensats.org');
  });

  test('rejects identifiers that cannot be a mailbox', () {
    expect(nip05MailAddress(null), isNull);
    expect(nip05MailAddress('opensats.org'), isNull);
    expect(nip05MailAddress('_@opensats.org'), isNull);
    expect(nip05MailAddress('@opensats.org'), isNull);
    expect(nip05MailAddress('bob@localhost'), isNull);
    expect(nip05MailAddress('npub1abc@uid.ovh'), isNull);
  });
}
