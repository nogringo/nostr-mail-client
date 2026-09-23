import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_core/controllers/scheduled_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';
import 'package:nmail_core/widgets/selectable_avatar.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'scheduled_recipient_avatar.dart';
import 'scheduled_send_time.dart';
import 'scheduled_status_chip.dart';

/// Taller ListTile layout for a scheduled email (mobile and tablet), mirroring
/// [EmailTile]'s default tile: long-press selects, and so does a tap on the
/// leading avatar, which becomes a check when selected.
class ScheduledEmailDefaultTile extends StatelessWidget {
  final ScheduledEmail email;
  final String subject;
  final String recipientName;
  final String sendTime;
  final ScheduledDisplayStatus? status;
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
    required this.status,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // The row paints its own separator, so no strip falls outside it.
      foregroundDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: ListTile(
        selected: isSelected,
        selectedColor: colorScheme.onSurface,
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
        onTap: selectionMode ? onToggleSelect : onOpen,
        onLongPress: onToggleSelect,
        isThreeLine: true,
        leading: SelectableAvatar(
          id: email.packageId,
          hoveredId: Get.find<ScheduledController>().hoveredId,
          avatar: ScheduledRecipientAvatar(email: email),
          isSelected: isSelected,
          onToggle: onToggleSelect,
          semanticsLabel: AppLocalizations.of(context).emailSelectRow,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                recipientName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ScheduledSendTime(sendTime: sendTime, fontSize: 11),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (status != null) ...[
                  ScheduledStatusChip(status: status!),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    email.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
