import 'package:flutter/material.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'scheduled_recipient_avatar.dart';
import 'scheduled_send_time.dart';
import 'scheduled_status_chip.dart';

/// Dense single-line row for a scheduled email on desktop, mirroring
/// [EmailTile]'s compact tile so the Scheduled list matches Sent.
class ScheduledEmailCompactTile extends StatelessWidget {
  final ScheduledEmail email;
  final String subject;
  final String recipientName;
  final String sendTime;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback? onOpen;

  const ScheduledEmailCompactTile({
    super.key,
    required this.email,
    required this.subject,
    required this.recipientName,
    required this.sendTime,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: selectionMode ? onToggleSelect : onOpen,
      child: Container(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelect(),
              ),
            ),
            SizedBox(
              width: 160,
              child: Row(
                children: [
                  ScheduledRecipientAvatar(email: email, radius: 14),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recipientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '—',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 3,
                    child: email.hasVisibleStatus
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: ScheduledStatusChip(status: email.status),
                          )
                        : Text(
                            email.bodyPreview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ScheduledSendTime(sendTime: sendTime, fontSize: 12),
          ],
        ),
      ),
    );
  }
}
