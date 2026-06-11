import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_mail_client/utils/contact_birthday_utils.dart';

void main() {
  group('ContactBirthday', () {
    test('value equality compares year, month and day', () {
      expect(
        const ContactBirthday(year: 1990, month: 4, day: 12),
        const ContactBirthday(year: 1990, month: 4, day: 12),
      );
      expect(
        const ContactBirthday(month: 4, day: 12),
        const ContactBirthday(month: 4, day: 12),
      );
      expect(
        const ContactBirthday(year: 1990, month: 4, day: 12),
        isNot(const ContactBirthday(month: 4, day: 12)),
      );
    });

    test('a year-less birthday has a null year', () {
      const birthday = ContactBirthday(month: 6, day: 11);
      expect(birthday.year, isNull);
      expect(birthday.month, 6);
      expect(birthday.day, 11);
    });
  });
}
