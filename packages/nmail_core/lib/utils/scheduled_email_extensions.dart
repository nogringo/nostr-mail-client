import 'package:nostr_mail/nostr_mail.dart';

/// What a row in the Scheduled list tells the user about its email.
enum ScheduledDisplayStatus {
  pending,
  scheduled,
  sending,
  overdue,
  failed,
  error,
}

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

  /// Once some recipients have it, editing would send it to them twice and
  /// cancelling would only stop it for the others.
  bool get canEdit => !isFinished && status != ScheduledEmailStatus.sending;

  /// The DVM's explanation for a failure, else the body preview.
  String get detail => switch (status) {
    ScheduledEmailStatus.failed ||
    ScheduledEmailStatus.error => statusMessage ?? bodyPreview,
    _ => bodyPreview,
  };

  /// Null when [isFinished].
  ScheduledDisplayStatus? displayStatus(DateTime now) => switch (status) {
    ScheduledEmailStatus.published || ScheduledEmailStatus.cancelled => null,
    ScheduledEmailStatus.failed => ScheduledDisplayStatus.failed,
    ScheduledEmailStatus.error => ScheduledDisplayStatus.error,
    _ when now.isAfter(scheduleAt.add(scheduledOverdueGrace)) =>
      ScheduledDisplayStatus.overdue,
    ScheduledEmailStatus.pending => ScheduledDisplayStatus.pending,
    ScheduledEmailStatus.scheduled => ScheduledDisplayStatus.scheduled,
    ScheduledEmailStatus.sending => ScheduledDisplayStatus.sending,
  };
}
