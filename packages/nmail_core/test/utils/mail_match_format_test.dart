import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/l10n/generated/app_localizations_en.dart';
import 'package:nmail_core/utils/mail_match_format.dart';
import 'package:nostr_mail/nostr_mail.dart';

void main() {
  group('Mail match format', () {
    test('splits a field on commas and drops the empty entries', () {
      expect(parseMatchList(' github.com, ,gitlab.com '), [
        'github.com',
        'gitlab.com',
      ]);
      expect(parseMatchList(' , '), isNull);
    });

    test('builds no match when every field is empty', () {
      expect(
        buildMailMatch(from: ' ', subject: '', hasAttachment: null),
        isNull,
      );
    });

    test('builds a match from the filled fields only', () {
      final match = buildMailMatch(
        from: 'github.com',
        subject: '',
        hasAttachment: false,
      )!;

      expect(match.toJson(), {
        'from': ['github.com'],
        'has_attachment': false,
      });
    });

    test('keeps the fields it does not know from the original match', () {
      final original = MailMatch.fromJson({
        'subject': ['invoice'],
        'body': ['due'],
      });

      final match = buildMailMatch(
        from: 'billing.example.com',
        subject: '',
        hasAttachment: null,
        original: original,
      )!;

      expect(match.toJson(), {
        'from': ['billing.example.com'],
        'body': ['due'],
      });
    });

    test('describes a match one condition at a time', () {
      final l = AppLocalizationsEn();
      const match = MailMatch(
        from: ['github.com', 'gitlab.com'],
        subject: ['release'],
        hasAttachment: true,
      );

      expect(
        describeMailMatch(l, match),
        'From github.com, gitlab.com; Subject contains release; '
        'With attachments',
      );
    });
  });
}
