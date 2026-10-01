import 'package:nostr_mail/nostr_mail.dart';

/// The emails of one sender, latest first.
typedef SenderGroup = ({String senderKey, List<EmailSummary> emails});

/// Groups [emails] by [EmailSummary.senderKey], the sender whose latest email
/// is the most recent first.
List<SenderGroup> groupBySender(Iterable<EmailSummary> emails) {
  final bySender = <String, List<EmailSummary>>{};
  for (final email in emails) {
    bySender.putIfAbsent(email.senderKey, () => []).add(email);
  }
  final groups = [
    for (final MapEntry(key: senderKey, value: emails) in bySender.entries)
      (
        senderKey: senderKey,
        emails: emails..sort((a, b) => b.date.compareTo(a.date)),
      ),
  ];
  return groups
    ..sort((a, b) => b.emails.first.date.compareTo(a.emails.first.date));
}
