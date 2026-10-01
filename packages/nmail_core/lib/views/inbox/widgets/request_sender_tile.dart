import 'package:enough_mail_plus/enough_mail.dart' show MailAddress;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../app/routes/app_routes.dart';
import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/format_date.dart';
import 'package:nmail_core/utils/run_sender_verdict.dart';
import 'package:nmail_core/utils/sender_groups.dart';
import 'package:nmail_core/views/email/widgets/person_avatar.dart';
import 'request_email_row.dart';

/// A sender waiting in requests: who they are, what they sent last, and the
/// verdict to give them. Tapping it opens the latest email.
class RequestSenderTile extends GetView<InboxController> {
  final SenderGroup group;

  const RequestSenderTile({super.key, required this.group});

  EmailSummary get _latest => group.emails.first;

  /// A bridged email names its sender in the MIME From, the gift wrap only
  /// the bridge.
  EmailPerson get _person => _latest.isBridged
      ? EmailPerson.email(
          MailAddress(_latest.fromName, _latest.from),
          bridgePubkey: _latest.senderPubkey,
        )
      : EmailPerson.nostr(_latest.senderPubkey);

  void _open(BuildContext context, EmailSummary email) =>
      context.go(AppRoutes.emailPath(Mailbox.requests, email.id));

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

    return Obx(() {
      final name = emailPersonName(_person);
      final address = _latest.isBridged && name != _latest.from
          ? _latest.from
          : null;
      final isUnread = !controller.isEmailRead(_latest.id);
      final isExpanded = controller.expandedSenders.contains(group.senderKey);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: PersonAvatar(person: _person),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDate(context, _latest.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address != null)
                  Text(address, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  _latest.subject.isEmpty ? l.emailNoSubject : _latest.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: isUnread ? FontWeight.w600 : null,
                  ),
                ),
                OverflowBar(
                  alignment: count > 1
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  overflowAlignment: OverflowBarAlignment.end,
                  children: [
                    if (count > 1)
                      TextButton.icon(
                        // Starts flush with the text above, not 12 in.
                        style: TextButton.styleFrom(
                          padding: const EdgeInsetsDirectional.only(end: 16),
                        ),
                        onPressed: () =>
                            controller.toggleSenderExpanded(group.senderKey),
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        label: Text(l.requestsEmailCount(count)),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _judge(context, SenderVerdict.block),
                          child: Text(l.requestsRefuse),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () => _judge(context, SenderVerdict.allow),
                          child: Text(l.requestsAccept),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _open(context, _latest),
          ),
          if (isExpanded)
            for (final email in group.emails)
              RequestEmailRow(email: email, onTap: () => _open(context, email)),
        ],
      );
    });
  }
}
