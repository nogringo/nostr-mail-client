import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';
import 'package:nostr_mail/nostr_mail.dart';

void main() {
  group('ScheduledEmailX', () {
    test('firstRecipient prefers to, then cc, then bcc', () {
      expect(
        _scheduled(to: ['to@example.com']).firstRecipient,
        'to@example.com',
      );
      expect(
        _scheduled(cc: ['cc@example.com']).firstRecipient,
        'cc@example.com',
      );
      expect(
        _scheduled(bcc: ['bcc@example.com']).firstRecipient,
        'bcc@example.com',
      );
      expect(_scheduled().firstRecipient, isEmpty);
    });

    test('isFinished covers published and cancelled only', () {
      final finished = ScheduledEmailStatus.values
          .where((s) => _scheduled(status: s).isFinished)
          .toSet();
      expect(finished, {
        ScheduledEmailStatus.published,
        ScheduledEmailStatus.cancelled,
      });
    });

    group('displayStatus', () {
      final before = _scheduleAt.subtract(const Duration(hours: 1));
      final withinGrace = _scheduleAt.add(const Duration(minutes: 1));
      final after = _scheduleAt.add(const Duration(hours: 1));

      test('maps pending and scheduled before the send time', () {
        expect(
          _scheduled(
            status: ScheduledEmailStatus.pending,
          ).displayStatus(before),
          ScheduledDisplayStatus.pending,
        );
        expect(
          _scheduled(
            status: ScheduledEmailStatus.scheduled,
          ).displayStatus(before),
          ScheduledDisplayStatus.scheduled,
        );
      });

      test('turns pending and scheduled overdue after the grace period', () {
        for (final status in [
          ScheduledEmailStatus.pending,
          ScheduledEmailStatus.scheduled,
        ]) {
          expect(
            _scheduled(status: status).displayStatus(withinGrace),
            isNot(ScheduledDisplayStatus.overdue),
          );
          expect(
            _scheduled(status: status).displayStatus(after),
            ScheduledDisplayStatus.overdue,
          );
        }
      });

      test('keeps failed and error regardless of time', () {
        expect(
          _scheduled(status: ScheduledEmailStatus.failed).displayStatus(after),
          ScheduledDisplayStatus.failed,
        );
        expect(
          _scheduled(status: ScheduledEmailStatus.error).displayStatus(after),
          ScheduledDisplayStatus.error,
        );
      });

      test('is null for finished emails', () {
        expect(
          _scheduled(
            status: ScheduledEmailStatus.published,
          ).displayStatus(before),
          isNull,
        );
        expect(
          _scheduled(
            status: ScheduledEmailStatus.cancelled,
          ).displayStatus(after),
          isNull,
        );
      });
    });
  });
}

final _scheduleAt = DateTime.utc(2026, 9, 19, 16, 22);

ScheduledEmail _scheduled({
  List<String> to = const [],
  List<String> cc = const [],
  List<String> bcc = const [],
  ScheduledEmailStatus status = ScheduledEmailStatus.pending,
}) {
  return ScheduledEmail(
    packageId: 'package-id',
    scheduleAt: _scheduleAt,
    from: 'sender@example.com',
    to: to,
    cc: cc,
    bcc: bcc,
    subject: 'Subject',
    bodyPreview: 'Preview',
    isPublic: false,
    attachmentNames: const [],
    status: status,
    createdAt: DateTime.utc(2026),
  );
}
