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

    test('hasVisibleStatus only surfaces terminal publish/error states', () {
      expect(
        _scheduled(status: ScheduledEmailStatus.published).hasVisibleStatus,
        isTrue,
      );
      expect(
        _scheduled(status: ScheduledEmailStatus.failed).hasVisibleStatus,
        isTrue,
      );
      expect(
        _scheduled(status: ScheduledEmailStatus.error).hasVisibleStatus,
        isTrue,
      );
      expect(
        _scheduled(status: ScheduledEmailStatus.pending).hasVisibleStatus,
        isFalse,
      );
      expect(
        _scheduled(status: ScheduledEmailStatus.scheduled).hasVisibleStatus,
        isFalse,
      );
      expect(
        _scheduled(status: ScheduledEmailStatus.cancelled).hasVisibleStatus,
        isFalse,
      );
    });
  });
}

ScheduledEmail _scheduled({
  List<String> to = const [],
  List<String> cc = const [],
  List<String> bcc = const [],
  ScheduledEmailStatus status = ScheduledEmailStatus.pending,
}) {
  return ScheduledEmail(
    packageId: 'package-id',
    scheduleAt: DateTime.utc(2026),
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
