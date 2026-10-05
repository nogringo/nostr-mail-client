import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart' show Email, ScheduledEmail;
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/models/compose_mode.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/views/compose/widgets/bottom_toolbar_view.dart';
import 'package:nmail_core/views/compose/widgets/schedule_send_button.dart';
import 'package:nmail_core/views/compose/widgets/scrollable_content_view.dart';
import 'package:nmail_core/views/compose/widgets/send_button_menu.dart';
import 'package:nmail_core/widgets/controller_builder.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';

class ComposeView extends StatelessWidget {
  const ComposeView({
    super.key,
    this.sourceEmail,
    this.sourceMode,
    this.initialRecipient,
    this.editingScheduled,
  });

  final Email? sourceEmail;
  final ComposeMode? sourceMode;
  final Recipient? initialRecipient;
  final ScheduledEmail? editingScheduled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isNotMobile(context);

    return ControllerBuilder(
      create: () => ComposeController(
        sourceEmail: sourceEmail,
        sourceMode: sourceMode,
        initialRecipient: initialRecipient,
        editingScheduled: editingScheduled,
      )..init(),
      builder: (context, controller) => Scaffold(
        appBar: AppBar(
          title: Text(l.composeTitle),
          actionsPadding: .only(right: 8),
          actions: [
            if (!isWide) ...[
              ScheduleSendButton(controller: controller),
              const SizedBox(width: 4),
              SendButtonMenu(controller: controller, isMobile: true),
            ],
          ],
        ),
        // One tree at any width: a remount disposes the recipients' focus nodes.
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ScrollableContentView(controller: controller),
                ),
              ),
              if (isWide) BottomToolbarView(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
