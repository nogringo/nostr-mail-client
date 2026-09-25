import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/views/inbox/widgets/attachment_chip_view.dart';
import 'package:nmail_core/views/inbox/widgets/email_tile.dart';
import 'package:nmail_core/widgets/selectable_avatar.dart';

/// Widths that pick each layout: the ListTile below 900, the compact row above.
const _widths = [400.0, 700.0, 1200.0];

EmailSummary _email([String id = 'a']) => EmailSummary(
  id: id,
  senderPubkey: '',
  from: 'alice@example.com',
  fromName: 'Alice Example',
  to: [MailAddress('Me', 'me@example.com')],
  subject: 'Subject $id',
  preview: 'Here is the summary you asked for last week.',
  date: DateTime.now().subtract(const Duration(hours: 2)),
  folder: 'inbox',
  isRead: true,
  isStarred: false,
  isPublic: false,
  isBridged: false,
  attachmentRefs: const [
    AttachmentRef(
      contentType: 'application/pdf',
      size: 1024,
      sha256: 'abc',
      filename: 'report.pdf',
    ),
  ],
);

Future<void> _pumpTiles(
  WidgetTester tester,
  double width, {
  List<String> ids = const ['a'],
}) async {
  tester.view.physicalSize = Size(width, 400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: ListView(
          children: [
            for (final id in ids)
              EmailTile(email: _email(id), onTap: () {}, onToggleSelect: () {}),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
    pointer: 1,
  );
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

MouseCursor? get _activeCursor =>
    RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1);

void main() {
  late Ndk ndk;

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
    Get.put(MailboxesController());
    Get.put(InboxController());
  });

  tearDown(() async {
    Get.reset();
    await ndk.destroy();
  });

  // InkWell defaults to adaptiveClickable, an arrow off the web, while ListTile
  // always resolves to the hand, and a callback-less Chip reports itself
  // disabled. Left alone the cursor would change with the layout, and again
  // over an attachment.
  for (final width in _widths) {
    testWidgets('the whole row shows the hand at ${width.toInt()}px', (
      tester,
    ) async {
      await _pumpTiles(tester, width);
      final gesture = await _mouse(tester);

      for (final target in [
        find.text('Subject a'),
        find.byType(SelectableAvatar),
        find.byType(AttachmentChipView),
      ]) {
        await gesture.moveTo(tester.getCenter(target));
        await tester.pumpAndSettle();
        expect(_activeCursor, SystemMouseCursors.click);
      }
    });

    // The separator used to be a sibling widget, leaving a strip the row's
    // cursor never reached: the pointer flickered between two rows.
    testWidgets('the hand survives the seam at ${width.toInt()}px', (
      tester,
    ) async {
      await _pumpTiles(tester, width, ids: ['a', 'b']);
      final gesture = await _mouse(tester);

      final seam = tester.getRect(find.byType(EmailTile).first).bottom;
      for (var y = seam - 2; y <= seam + 2; y += 0.5) {
        await gesture.moveTo(Offset(width / 2, y));
        await tester.pumpAndSettle();
        expect(_activeCursor, SystemMouseCursors.click, reason: 'at y=$y');
      }
    });
  }
}
