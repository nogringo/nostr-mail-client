import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nmail_core/controllers/drafts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/widgets/selectable_avatar.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'draft_recipient_avatar.dart';

/// Taller ListTile layout for a draft (mobile and tablet), mirroring
/// [EmailTile]'s default tile: long-press selects, and so does a tap on the
/// leading avatar, which becomes a check when selected.
class DraftDefaultTile extends StatelessWidget {
  final Draft draft;
  final String subject;
  final String recipientName;
  final String date;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback onOpen;

  const DraftDefaultTile({
    super.key,
    required this.draft,
    required this.subject,
    required this.recipientName,
    required this.date,
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
          id: draft.draftId,
          hoveredId: GetIt.I<DraftsController>().hoveredId,
          avatar: DraftRecipientAvatar(draft: draft),
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
            Text(
              date,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
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
            Text(
              draft.bodyPreview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
