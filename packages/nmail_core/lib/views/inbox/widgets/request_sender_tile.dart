import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/format_date.dart';
import 'package:nmail_core/utils/run_sender_verdict.dart';
import 'package:nmail_core/utils/sender_groups.dart';
import 'package:nmail_core/views/email/widgets/bridged_person_avatar.dart';

/// A sender waiting in requests: who they are, what they sent last, and the
/// verdict to give them. Tapping it shows what they sent: the email itself
/// when there is one, the list of them otherwise.
class RequestSenderTile extends StatelessWidget {
  final SenderGroup group;

  const RequestSenderTile({super.key, required this.group});

  InboxController get controller => GetIt.I<InboxController>();

  EmailSummary get _latest => group.emails.first;

  void _open(BuildContext context) => context.go(
    group.emails.length > 1
        ? AppRoutes.requestSenderPath(group.senderKey)
        : AppRoutes.emailPath(Mailbox.requests, _latest.id),
  );

  Future<void> _judge(BuildContext context, SenderVerdict verdict) =>
      runSenderVerdict(
        context,
        () => controller.setSenderVerdict([group.senderKey], verdict),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final count = group.emails.length;

    final person = summarySender(_latest);

    return Obx(() {
      final name = emailPersonName(person);
      final address = _latest.isBridged && name != _latest.from
          ? _latest.from
          : null;
      final isUnread = !controller.isEmailRead(_latest.id);

      return ListTile(
        titleAlignment: ListTileTitleAlignment.top,
        leading: BridgedPersonAvatar(person: person),
        title: Row(
          children: [
            Expanded(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Padding(
              // Ends where the thumb's glyph does, inside its button.
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: Text(
                formatDate(context, _latest.date),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (address != null)
                    Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    _latest.subject.isEmpty
                        ? l.emailNoSubject
                        : _latest.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: isUnread ? FontWeight.w600 : null,
                    ),
                  ),
                  if (count > 1) Text(l.requestsEmailCount(count)),
                ],
              ),
            ),
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
          ],
        ),
        onTap: () => _open(context),
      );
    });
  }
}
