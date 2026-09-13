import 'package:flutter/material.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/format_date_time.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/views/email/widgets/person_name.dart';
import 'package:nmail_core/views/email/widgets/sender_avatar_view.dart';

class SenderRowView extends StatelessWidget {
  const SenderRowView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = EmailController.to;
    final email = controller.email!;

    final to = email.mime.to ?? [];
    final cc = email.mime.cc ?? [];
    final bcc = email.mime.bcc ?? [];
    final recipientCount = to.length + cc.length + bcc.length;

    return Row(
      children: [
        SenderAvatarView(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PersonName(
                person: controller.senderPerson,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    formatDateTime(context, email.date),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      controller.showRecipients = !controller.showRecipients;
                      controller.update();
                    },
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.showRecipients
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$recipientCount',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    tooltip: l.emailShowRecipients,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
