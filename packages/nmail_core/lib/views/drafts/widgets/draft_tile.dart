import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HardwareKeyboard;
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/draft_extensions.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/format_date.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'draft_compact_tile.dart';
import 'draft_default_tile.dart';

/// A draft rendered like a Sent email row. Mirrors [EmailTile]: a dense
/// compact row on desktop, a taller ListTile elsewhere, selection and deletion
/// working the same way as the Sent list.
class DraftTile extends StatelessWidget {
  final Draft draft;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onToggleSelect;

  /// Selects everything between the last toggled row and this one, on
  /// shift-click.
  final VoidCallback onExtendSelect;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const DraftTile({
    super.key,
    required this.draft,
    required this.isSelected,
    required this.selectionMode,
    required this.onToggleSelect,
    required this.onExtendSelect,
    required this.onDelete,
    required this.onOpen,
  });

  VoidCallback _unlessShift(VoidCallback action) =>
      () => HardwareKeyboard.instance.isShiftPressed
      ? onExtendSelect()
      : action();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final subject = draft.subject.trim().isEmpty
        ? l.emailNoSubject
        : draft.subject;
    final recipient = draft.firstRecipientPerson;
    final recipientName = recipient == null
        ? l.draftsNoRecipients
        : emailPersonName(recipient);
    final date = formatDate(context, draft.updatedAt);
    final onToggleSelect = _unlessShift(this.onToggleSelect);
    final onOpen = _unlessShift(this.onOpen);

    final tile = ResponsiveHelper.isDesktop(context)
        ? DraftCompactTile(
            draft: draft,
            subject: subject,
            recipientName: recipientName,
            date: date,
            isSelected: isSelected,
            selectionMode: selectionMode,
            onToggleSelect: onToggleSelect,
            onOpen: onOpen,
          )
        : DraftDefaultTile(
            draft: draft,
            subject: subject,
            recipientName: recipientName,
            date: date,
            isSelected: isSelected,
            selectionMode: selectionMode,
            onToggleSelect: onToggleSelect,
            onOpen: onOpen,
          );

    return Dismissible(
      key: ValueKey(draft.draftId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onSecondaryTapUp: (details) =>
            _showContextMenu(context, details.globalPosition),
        child: tile,
      ),
    );
  }

  /// Right-click (desktop) menu, mirroring EmailTile. Mobile uses long-press to
  /// select instead, so there is no bottom sheet here.
  void _showContextMenu(BuildContext context, Offset position) {
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
                    Icons.delete_outline,
                    color: colorScheme.error,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                  child: Text(
                    l.actionDelete,
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
