import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'delete_permanently_dialog.dart';

class SpamBanner extends StatelessWidget {
  const SpamBanner({super.key});

  InboxController get controller => GetIt.I<InboxController>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.currentMailbox.isSpam ||
            controller.isSearching ||
            controller.emails.isEmpty) {
          return const SizedBox.shrink();
        }

        final isDeleting = controller.isDeletingPermanently;
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
      },
    );
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
