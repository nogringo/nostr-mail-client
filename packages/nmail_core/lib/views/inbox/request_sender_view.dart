import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/run_sender_verdict.dart';
import 'widgets/email_tile.dart';

/// What one sender waiting in requests sent, to read before giving a verdict.
/// Its rows come from the requests listing under it in the stack.
class RequestSenderView extends StatelessWidget {
  final String senderKey;

  const RequestSenderView({super.key, required this.senderKey});

  InboxController get controller => GetIt.I<InboxController>();

  /// The verdict takes every email of the sender out of requests, so the page
  /// goes with them.
  Future<void> _judge(BuildContext context, SenderVerdict verdict) async {
    final applied = await runSenderVerdict(
      context,
      () => controller.setSenderVerdict([senderKey], verdict),
    );
    if (applied && context.mounted) context.go(AppRoutes.requests);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final emails = [
          for (final email in controller.emails)
            if (email.senderKey == senderKey) email,
        ];

        return Scaffold(
          appBar: AppBar(
            title: emails.isEmpty
                ? null
                : Text(
                    emailPersonName(summarySender(emails.first)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            actions: [
              IconButton(
                icon: const Icon(Icons.thumb_down_outlined),
                tooltip: l.senderBlock,
                onPressed: () => _judge(context, SenderVerdict.block),
              ),
              IconButton(
                icon: const Icon(Icons.thumb_up_outlined),
                tooltip: l.senderAccept,
                onPressed: () => _judge(context, SenderVerdict.allow),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: emails.isEmpty
              ? Center(child: Text(l.inboxEmptyRequests))
              : ListView.builder(
                  itemCount: emails.length,
                  itemBuilder: (context, index) {
                    final email = emails[index];
                    return EmailTile(
                      key: ValueKey(email.id),
                      email: email,
                      onTap: () => context.go(
                        AppRoutes.requestSenderEmailPath(senderKey, email.id),
                      ),
                      onDelete: () => controller.moveToTrash(email.id),
                      onSenderVerdict: (verdict) => _judge(context, verdict),
                    );
                  },
                ),
        );
      },
    );
  }
}
