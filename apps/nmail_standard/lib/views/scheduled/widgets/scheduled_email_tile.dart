import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/metadata_service.dart';
import '../../../utils/format_date.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/utils/nostr_utils.dart';
import '../../../utils/responsive_helper.dart';
import '../../../utils/scheduled_email_extensions.dart';
import 'scheduled_email_compact_tile.dart';
import 'scheduled_email_default_tile.dart';

/// A scheduled email rendered like a Sent email row: it is, after all, an
/// email that has not gone out yet. Mirrors [EmailTile]: a dense compact row
/// with a selection checkbox on desktop, a taller ListTile elsewhere, selection
/// and cancellation working the same way as the Sent list.
class ScheduledEmailTile extends StatelessWidget {
  final ScheduledEmail email;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback onCancel;
  final VoidCallback onOpen;

  const ScheduledEmailTile({
    super.key,
    required this.email,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onCancel,
    required this.onOpen,
  });

  bool get _canCancel =>
      email.status != ScheduledEmailStatus.published &&
      email.status != ScheduledEmailStatus.cancelled;

  /// A schedule that can still be cancelled can also be re-opened for editing.
  bool get _canEdit => _canCancel;

  String _recipientName(BuildContext context) {
    final pubkey = extractPubkeyFromAddress(email.firstRecipient) ?? '';
    if (pubkey.isNotEmpty) {
      final metadata = Get.find<MetadataService>().of(pubkey).value;
      if (metadata != null) return metadata.getBestName();
    }
    return email.firstRecipient;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final subject = email.subject.trim().isEmpty
        ? l.emailNoSubject
        : email.subject;
    final recipientName = _recipientName(context);
    final sendTime = formatDateTime(context, email.scheduleAt);

    final onOpen = _canEdit ? this.onOpen : null;
    final tile = ResponsiveHelper.isDesktop(context)
        ? ScheduledEmailCompactTile(
            email: email,
            subject: subject,
            recipientName: recipientName,
            sendTime: sendTime,
            isSelected: isSelected,
            selectionMode: selectionMode,
            onToggleSelect: onToggleSelect,
            onOpen: onOpen,
          )
        : ScheduledEmailDefaultTile(
            email: email,
            subject: subject,
            recipientName: recipientName,
            sendTime: sendTime,
            isSelected: isSelected,
            selectionMode: selectionMode,
            onToggleSelect: onToggleSelect,
            onOpen: onOpen,
          );

    return Column(
      children: [
        Dismissible(
          key: ValueKey(email.packageId),
          direction: _canCancel
              ? DismissDirection.endToStart
              : DismissDirection.none,
          background: Container(
            color: colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.cancel_schedule_send, color: colorScheme.onError),
          ),
          onDismissed: (_) => onCancel(),
          child: GestureDetector(
            onSecondaryTapUp: (details) =>
                _showContextMenu(context, details.globalPosition),
            child: tile,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  /// Right-click (desktop) menu, mirroring EmailTile. Mobile uses long-press to
  /// select instead, so there is no bottom sheet here.
  void _showContextMenu(BuildContext context, Offset position) {
    if (!_canCancel) return;
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(onTap: () => Navigator.of(context).pop()),
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              surfaceTintColor: colorScheme.surfaceTint,
              child: IntrinsicWidth(
                child: MenuItemButton(
                  leadingIcon: Icon(
                    Icons.cancel_schedule_send,
                    color: colorScheme.error,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCancel();
                  },
                  child: Text(
                    l.scheduledCancel,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
