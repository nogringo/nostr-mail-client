import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/inbox_controller.dart';
import '../../../controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// In the inbox, while senders wait in requests for a verdict.
class PendingSendersBanner extends StatelessWidget {
  const PendingSendersBanner({super.key});

  InboxController get controller => GetIt.I<InboxController>();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mailboxes = GetIt.I<MailboxesController>();

    return ListenableBuilder(
      listenable: Listenable.merge([controller, mailboxes.pendingSenders]),
      builder: (context, _) {
        final pending = mailboxes.pendingSenders.value;
        if (!controller.currentMailbox.isInbox ||
            controller.isSearching ||
            pending == 0) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          leading: const Icon(Icons.how_to_reg_outlined),
          content: Text(l.pendingSendersBannerMessage(pending)),
          actions: [
            TextButton(
              onPressed: () => context.go(AppRoutes.requests),
              child: Text(l.pendingSendersBannerReview),
            ),
          ],
        );
      },
    );
  }
}
