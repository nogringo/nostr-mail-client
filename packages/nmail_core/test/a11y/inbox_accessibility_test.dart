import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/views/inbox/widgets/email_tile.dart';

const _mobileWidth = 400.0;
const _desktopWidth = 1200.0;

/// Empty sender pubkey so the avatar resolves locally, with no metadata
/// lookup and no network image.
EmailSummary _receivedEmail({
  String subject = 'Quarterly report',
  List<AttachmentRef> attachments = const [],
}) {
  return EmailSummary(
    id: 'event-1',
    senderPubkey: '',
    from: 'alice@example.com',
    fromName: 'Alice Example',
    to: [MailAddress('Me', 'me@example.com')],
    subject: subject,
    preview: 'Here is the summary you asked for last week.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    folder: 'inbox',
    isRead: false,
    isStarred: false,
    isPublic: false,
    isBridged: false,
    attachmentRefs: attachments,
  );
}

Future<void> _pumpTile(
  WidgetTester tester, {
  required double width,
  EmailSummary? email,
}) async {
  tester.view.physicalSize = Size(width, 900);
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
            EmailTile(
              email: email ?? _receivedEmail(),
              onTap: () {},
              onToggleSelect: () {},
              onDelete: () {},
              onArchive: () {},
              onRestore: () {},
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
}

List<String> _semanticsLabels(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    if (node.label.isNotEmpty) labels.add(node.label);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(tester.getSemantics(find.byType(EmailTile)));
  return labels;
}

List<String> _customActionLabels(WidgetTester tester) {
  final data = tester.getSemantics(find.byType(EmailTile)).getSemanticsData();
  return (data.customSemanticsActionIds ?? const [])
      .map((id) => CustomSemanticsAction.getAction(id)?.label ?? '')
      .toList();
}

void main() {
  late Ndk ndk;

  setUp(() {
    Get.testMode = true;
    // Never log this ndk in: InboxController.onInit would then call
    // activateForCurrentAccount and touch the uninitialised client.
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
    Get.put(InboxController());
  });

  tearDown(() async {
    Get.reset();
    await ndk.destroy();
  });

  group('inbox row, mobile layout', () {
    testWidgets('meets the Android tap target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('meets the iOS tap target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every tappable node carries a label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('text meets the contrast guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('announces the unread state', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      expect(
        _semanticsLabels(tester).join(' | ').toLowerCase(),
        contains('unread'),
      );
      handle.dispose();
    });

    testWidgets('reads the row as one node, not as fragments', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      final node = tester.getSemantics(find.byType(EmailTile));
      expect(_semanticsLabels(tester), hasLength(1));
      expect(
        node.label,
        startsWith(
          'Unread, Alice Example, Quarterly report, '
          'Here is the summary you asked for last week., ',
        ),
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('exposes the swipe gestures as custom actions', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _mobileWidth);
      expect(
        _customActionLabels(tester),
        containsAll(['Select', 'Archive', 'Move to trash']),
      );
      handle.dispose();
    });
  });

  group('inbox row, desktop layout', () {
    testWidgets('meets the Android tap target guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _desktopWidth);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('every tappable node carries a label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _desktopWidth);
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('text meets the contrast guideline', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(tester, width: _desktopWidth);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('the attachment overflow chip carries a label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpTile(
        tester,
        width: _desktopWidth,
        email: _receivedEmail(
          attachments: List.generate(
            4,
            (i) => AttachmentRef(
              filename: 'file-$i.pdf',
              contentType: 'application/pdf',
              size: 1024,
              sha256: '$i' * 64,
            ),
          ),
        ),
      );
      expect(
        _semanticsLabels(tester),
        isNot(contains(matches(RegExp(r'^\+\d+$')))),
        reason: 'the overflow chip announces a bare "+N" with no noun',
      );
      handle.dispose();
    });
  });
}
