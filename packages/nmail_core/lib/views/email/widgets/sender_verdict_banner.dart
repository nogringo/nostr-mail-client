import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import '../email_controller.dart';

/// The verdict an email opened from requests or spam is waiting for, kept in
/// sight above the scrolling message.
class SenderVerdictBanner extends StatelessWidget {
  const SenderVerdictBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<EmailController>();
    final mailbox = controller.mailbox;
    if (mailbox == null || !(mailbox.isRequests || mailbox.isSpam)) {
      return const SizedBox.shrink();
    }

    // Spelled out here, with the thumbs the Requests list shows alone.
    final actions = mailbox.isRequests
        ? [
            TextButton.icon(
              onPressed: () =>
                  controller.setSenderVerdict(context, SenderVerdict.block),
              icon: const Icon(Icons.thumb_down_outlined),
              label: Text(l.requestsBlock),
            ),
            TextButton.icon(
              onPressed: () =>
                  controller.setSenderVerdict(context, SenderVerdict.allow),
              icon: const Icon(Icons.thumb_up_outlined),
              label: Text(l.requestsAccept),
            ),
          ]
        : [
            TextButton(
              onPressed: () =>
                  controller.setSenderVerdict(context, SenderVerdict.allow),
              child: Text(l.senderUnblock),
            ),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= ResponsiveBreakpoints.mobile;

        return MaterialBanner(
          leading: Icon(
            mailbox.isRequests
                ? Icons.how_to_reg_outlined
                : Icons.report_outlined,
          ),
          content: Text(
            mailbox.isRequests ? l.emailRequestBanner : l.emailBlockedBanner,
          ),
          // MaterialBanner stays on one row only with a single action.
          actions: isWide
              ? [OverflowBar(spacing: 8, children: actions)]
              : actions,
        );
      },
    );
  }
}
