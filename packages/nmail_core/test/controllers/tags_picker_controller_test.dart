import 'package:enough_mail_plus/enough_mail.dart' show MailAddress;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/controllers/tags_picker_controller.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';

const _urgent = 'aaaaaaaaaaaaaaaa';
const _travel = 'bbbbbbbbbbbbbbbb';

EmailSummary _email(String id, {List<String> tags = const []}) => EmailSummary(
  id: id,
  senderPubkey: '',
  from: 'alice@example.com',
  to: [MailAddress('Me', 'me@example.com')],
  subject: 'Subject',
  preview: '',
  date: DateTime(2026),
  folder: 'inbox',
  isRead: true,
  isStarred: false,
  isPublic: false,
  isBridged: false,
  labels: [for (final tag in tags) 'tag:$tag'],
  tags: tags,
);

void main() {
  late Ndk ndk;
  late MailboxesController mailboxes;

  setUp(() {
    Get.testMode = true;
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(useIsolate: false),
        bootstrapRelays: const [],
        logLevel: LogLevel.off,
      ),
    );
    Get.put<Ndk>(ndk);
    Get.put(StorageService());
    Get.put(NotificationService());
    Get.put(NostrMailService());
    Get.put(AuthController()).activePubkey.value = 'f' * 64;
    mailboxes = Get.put(MailboxesController());
    mailboxes.tags.assignAll(const [
      MailEntry(id: _urgent, name: 'Urgent'),
      MailEntry(id: _travel, name: 'Travel'),
    ]);
  });

  tearDown(() async {
    Get.reset();
    await ndk.destroy();
  });

  group('TagsPickerController', () {
    test('starts with no change, whatever the emails carry', () {
      final picker = TagsPickerController([
        _email('1', tags: [_urgent]),
        _email('2'),
      ])..onInit();

      expect(picker.stateOf(_urgent), isNull);
      expect(picker.stateOf(_travel), isFalse);
      expect(picker.hasChanges, isFalse);
    });

    test('checking a tag no email has adds it', () {
      final picker = TagsPickerController([_email('1')])..onInit();

      picker.toggle(_travel);

      expect(picker.changes.add, {_travel});
      expect(picker.changes.remove, isEmpty);
    });

    test('unchecking a tag every email has removes it', () {
      final picker = TagsPickerController([
        _email('1', tags: [_urgent]),
      ])..onInit();

      picker.toggle(_urgent);

      expect(picker.changes.remove, {_urgent});
      expect(picker.hasChanges, isTrue);
    });

    test('a tag created from the picker is added once checked', () {
      final picker = TagsPickerController([_email('1')])..onInit();
      mailboxes.tags.add(const MailEntry(id: 'cccccccccccccccc', name: 'New'));

      picker.check('cccccccccccccccc');

      expect(picker.changes.add, {'cccccccccccccccc'});
    });
  });
}
