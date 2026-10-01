import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/run_sender_verdict.dart';
import 'accept_all_senders_dialog.dart';

/// Accepts every sender at once, as when the mail received before Requests
/// existed lands here.
class RequestsBanner extends GetView<InboxController> {
  const RequestsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Obx(() {
      if (!controller.currentMailbox.value.isRequests ||
          controller.isSearching ||
          controller.emails.isEmpty) {
        return const SizedBox.shrink();
      }

      final senderCount = controller.emails
          .map((email) => email.senderKey)
          .toSet()
          .length;

      return MaterialBanner(
        leading: const Icon(Icons.how_to_reg_outlined),
        content: Text(l.mailboxPendingSenders(senderCount)),
        actions: [
          TextButton(
            onPressed: () => _acceptAll(context, senderCount),
            child: Text(l.requestsAcceptAll),
          ),
        ],
      );
    });
  }

  Future<void> _acceptAll(BuildContext context, int senderCount) async {
    if (!await AcceptAllSendersDialog.confirm(context, senderCount)) return;
    if (!context.mounted) return;
    await runSenderVerdict(context, controller.acceptAllRequests);
  }
}
