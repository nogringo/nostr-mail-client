import 'package:nostr_mail/nostr_mail.dart';

extension ScheduledEmailX on ScheduledEmail {
  /// Primary recipient shown in the list: first To, else Cc, else Bcc.
  String get firstRecipient {
    if (to.isNotEmpty) return to.first;
    if (cc.isNotEmpty) return cc.first;
    if (bcc.isNotEmpty) return bcc.first;
    return '';
  }

  /// Whether the delivery status is worth surfacing as a chip. The ordinary
  /// pending/scheduled states are told by the send time alone.
  bool get hasVisibleStatus =>
      status == ScheduledEmailStatus.published ||
      status == ScheduledEmailStatus.failed ||
      status == ScheduledEmailStatus.error;
}
