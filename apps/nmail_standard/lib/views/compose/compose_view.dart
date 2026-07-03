import 'package:flutter/material.dart';
import 'package:nmail_standard/views/compose/widgets/bottom_toolbar_view.dart';
import 'package:nmail_standard/views/compose/widgets/schedule_send_button.dart';
import 'package:nmail_standard/views/compose/widgets/scrollable_content_view.dart';
import 'package:nmail_standard/views/compose/widgets/send_button_menu.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';

class ComposeView extends StatelessWidget {
  const ComposeView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWide = ResponsiveHelper.isNotMobile(context);

    final child = SingleChildScrollView(child: ScrollableContentView());

    Widget content = Scaffold(
      appBar: AppBar(
        title: Text(l.composeTitle),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          if (!isWide) ...[
            const ScheduleSendButton(),
            const SendButtonMenu(isMobile: true),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        child: isWide
            ? Column(
                children: [
                  Expanded(child: child),
                  BottomToolbarView(),
                ],
              )
            : child,
      ),
    );

    return content;
  }
}
