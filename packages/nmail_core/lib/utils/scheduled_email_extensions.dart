import 'package:nostr_mail/nostr_mail.dart';

/// What a row in the Scheduled list tells the user about its email.
enum ScheduledDisplayStatus { pending, scheduled, overdue, failed, error }

/// Leaves the DVM time to publish and send its feedback before a send time in
/// the past counts as overdue.
const scheduledOverdueGrace = Duration(minutes: 5);

extension ScheduledEmailX on ScheduledEmail {
  /// Primary recipient shown in the list: first To, else Cc, else Bcc.
  String get firstRecipient {
    if (to.isNotEmpty) return to.first;
    if (cc.isNotEmpty) return cc.first;
    if (bcc.isNotEmpty) return bcc.first;
    return '';
  }

  /// A published email lives in Sent, a cancelled one is gone: neither stays in
  /// the Scheduled list.
  bool get isFinished =>
      status == ScheduledEmailStatus.published ||
      status == ScheduledEmailStatus.cancelled;

  /// Null when [isFinished].
  ScheduledDisplayStatus? displayStatus(DateTime now) => switch (status) {
    ScheduledEmailStatus.published || ScheduledEmailStatus.cancelled => null,
    ScheduledEmailStatus.failed => ScheduledDisplayStatus.failed,
    ScheduledEmailStatus.error => ScheduledDisplayStatus.error,
    _ when now.isAfter(scheduleAt.add(scheduledOverdueGrace)) =>
      ScheduledDisplayStatus.overdue,
    ScheduledEmailStatus.pending => ScheduledDisplayStatus.pending,
    ScheduledEmailStatus.scheduled => ScheduledDisplayStatus.scheduled,
  };
}
