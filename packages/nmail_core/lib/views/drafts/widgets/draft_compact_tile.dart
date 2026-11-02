import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nmail_core/controllers/drafts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/widgets/selectable_avatar.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'draft_recipient_avatar.dart';

/// Dense single-line row for a draft on desktop, mirroring [EmailTile]'s
/// compact tile so the Drafts list matches Sent.
class DraftCompactTile extends StatelessWidget {
  final Draft draft;
  final String subject;
  final String recipientName;
  final String date;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;
  final VoidCallback onOpen;

  const DraftCompactTile({
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
                      id: draft.draftId,
                      hoveredId: GetIt.I<DraftsController>().hoveredId,
                      avatar: DraftRecipientAvatar(draft: draft, radius: 14),
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
                    if (draft.bodyPreview.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        flex: 3,
                        child: Text(
                          draft.bodyPreview,
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
              Text(
                date,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
