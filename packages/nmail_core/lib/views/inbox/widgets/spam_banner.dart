import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'delete_permanently_dialog.dart';

class SpamBanner extends GetView<InboxController> {
  const SpamBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Obx(() {
      if (!controller.currentMailbox.value.isSpam ||
          controller.isSearching ||
          controller.emails.isEmpty) {
        return const SizedBox.shrink();
      }

      final isDeleting = controller.isDeletingPermanently.value;
      final spamCount = controller.emails.length;

      return MaterialBanner(
        leading: isDeleting
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.report_outlined),
        content: Text(l.inboxSpamCount(spamCount)),
        actions: [
          TextButton(
            onPressed: isDeleting ? null : () => _empty(context, spamCount),
            child: Text(l.inboxEmptySpamAction),
          ),
        ],
      );
    });
  }

  Future<void> _empty(BuildContext context, int spamCount) {
    final l = AppLocalizations.of(context);
    return DeletePermanentlyDialog.confirmAndDelete(
      context,
      title: l.inboxEmptySpamTitle,
      message: l.inboxEmptySpamMessage(spamCount),
      confirmLabel: l.inboxEmptySpamAction,
      delete: controller.emptySpam,
    );
  }
}
