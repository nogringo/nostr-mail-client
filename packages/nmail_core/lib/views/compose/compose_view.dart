import 'package:flutter/material.dart';
import 'package:nmail_core/views/compose/widgets/bottom_toolbar_view.dart';
import 'package:nmail_core/views/compose/widgets/schedule_send_button.dart';
import 'package:nmail_core/views/compose/widgets/scrollable_content_view.dart';
import 'package:nmail_core/views/compose/widgets/send_button_menu.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';

class ComposeView extends StatelessWidget {
  const ComposeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isNotMobile(context);

    Widget content = Scaffold(
      appBar: AppBar(
        title: Text(l.composeTitle),
        actionsPadding: .only(right: 8),
        actions: [
          if (!isWide) ...[
            const ScheduleSendButton(),
            const SizedBox(width: 4),
            const SendButtonMenu(isMobile: true),
          ],
        ],
      ),
      // One tree at any width: a remount disposes the recipients' focus nodes.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(child: ScrollableContentView()),
            ),
            if (isWide) BottomToolbarView(),
          ],
        ),
      ),
    );

    return content;
  }
}
