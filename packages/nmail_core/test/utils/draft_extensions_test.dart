import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/utils/draft_extensions.dart';
import 'package:nostr_mail/nostr_mail.dart';

const _pubkey =
    '3bf0c63fcb93463407af97a5e5ee64fa883d107ef9e558472c4eb9aaaefa459d';

void main() {
  group('DraftX', () {
    test('firstRecipientPerson prefers to, then cc, then bcc', () {
      expect(
        _draft(
          to: ['to@example.com'],
          cc: ['cc@example.com'],
        ).firstRecipientPerson?.address?.email,
        'to@example.com',
      );
      expect(
        _draft(
          cc: ['cc@example.com'],
          bcc: ['bcc@example.com'],
        ).firstRecipientPerson?.address?.email,
        'cc@example.com',
      );
      expect(
        _draft(bcc: ['bcc@example.com']).firstRecipientPerson?.address?.email,
        'bcc@example.com',
      );
    });

    test('firstRecipientPerson is null without recipients', () {
      expect(_draft().firstRecipientPerson, isNull);
    });

    test('firstRecipientPerson reads the key of an npub address', () {
      final npub = Nip19.encodePubKey(_pubkey);
      expect(_draft(to: ['$npub@nostr']).firstRecipientPerson?.pubkey, _pubkey);
    });

    test('recipientCount counts every field', () {
      expect(
        _draft(
          to: ['a@x.com', 'b@x.com'],
          cc: ['c@x.com'],
          bcc: ['d@x.com'],
        ).recipientCount,
        4,
      );
    });
  });
}

Draft _draft({
  List<String> to = const [],
  List<String> cc = const [],
  List<String> bcc = const [],
}) => Draft(
  draftId: 'd',
  updatedAt: DateTime(2026, 11, 2),
  from: null,
  to: to,
  cc: cc,
  bcc: bcc,
  subject: '',
  bodyPreview: '',
  attachmentNames: const [],
);
