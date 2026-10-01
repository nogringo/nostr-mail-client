import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/sender_groups.dart';
import 'package:nostr_mail/nostr_mail.dart';

EmailSummary _email(String id, String senderKey, DateTime date) => EmailSummary(
  id: id,
  senderPubkey: senderKey,
  senderKey: senderKey,
  from: '$senderKey@example.com',
  subject: 'Subject $id',
  preview: '',
  date: date,
  folder: 'requests',
  isRead: false,
  isStarred: false,
  isPublic: false,
  isBridged: false,
);

void main() {
  test('puts each sender once, the one who wrote last first', () {
    final groups = groupBySender([
      _email('a1', 'alice', DateTime(2026, 1, 1)),
      _email('b1', 'bob', DateTime(2026, 1, 3)),
      _email('a2', 'alice', DateTime(2026, 1, 4)),
      _email('b2', 'bob', DateTime(2026, 1, 2)),
    ]);

    expect([for (final group in groups) group.senderKey], ['alice', 'bob']);
    expect([for (final email in groups.first.emails) email.id], ['a2', 'a1']);
    expect([for (final email in groups.last.emails) email.id], ['b1', 'b2']);
  });

  test('has no group without an email', () {
    expect(groupBySender(const []), isEmpty);
  });
}
