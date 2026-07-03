import 'package:flutter/material.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'scheduled_recipient_avatar.dart';
import 'scheduled_send_time.dart';
import 'scheduled_status_chip.dart';

/// Taller ListTile layout for a scheduled email (mobile and tablet), mirroring
/// [EmailTile]'s default tile: long-press selects, the leading avatar becomes a
/// check when selected.
class ScheduledEmailDefaultTile extends StatelessWidget {
  final ScheduledEmail email;
  final String subject;
  final String recipientName;
  final String sendTime;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback? onOpen;

  const ScheduledEmailDefaultTile({
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

    return ListTile(
      onTap: selectionMode ? onToggleSelect : onOpen,
      onLongPress: onToggleSelect,
      isThreeLine: true,
      leading: isSelected
          ? const CircleAvatar(child: Icon(Icons.check))
          : ScheduledRecipientAvatar(email: email),
      title: Text(
        subject,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipientName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 2),
          if (email.hasVisibleStatus)
            ScheduledStatusChip(status: email.status)
          else
            Text(
              email.bodyPreview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
        ],
      ),
      trailing: ScheduledSendTime(sendTime: sendTime, fontSize: 11),
    );
  }
}
