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

/// Dense single-line row for a scheduled email on desktop, mirroring
/// [EmailTile]'s compact tile so the Scheduled list matches Sent.
class ScheduledEmailCompactTile extends StatelessWidget {
  final ScheduledEmail email;
  final String subject;
  final String recipientName;
  final String sendTime;
  final ScheduledDisplayStatus? status;
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
    required this.status,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        // Matches ListTile's hand, which InkWell only uses on the web.
        mouseCursor: WidgetStateMouseCursor.clickable,
        onTap: selectionMode ? onToggleSelect : onOpen,
        child: Container(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          // The row paints its own separator, so no strip falls outside it.
          foregroundDecoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Row(
                  children: [
                    SelectableAvatar(
                      id: email.packageId,
                      hoveredId: Get.find<ScheduledController>().hoveredId,
                      avatar: ScheduledRecipientAvatar(
                        email: email,
                        radius: 14,
                      ),
                      radius: 14,
                      isSelected: isSelected,
                      onToggle: onToggleSelect,
                      semanticsLabel: l.emailSelectRow,
                    ),
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
                    if (status != null) ...[
                      const SizedBox(width: 8),
                      ScheduledStatusChip(status: status!),
                    ],
                    if (email.detail.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '—',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 3,
                        child: Text(
                          email.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ScheduledSendTime(sendTime: sendTime, fontSize: 12),
            ],
          ),
        ),
      ),
    );
  }
}
