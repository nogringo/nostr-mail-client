import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/string_color.dart';

/// A user tag, tinted with its color. A tag with no entry shows its [id].
class TagChip extends StatelessWidget {
  final String id;
  final MailEntry? tag;
  final VoidCallback? onDeleted;

  const TagChip({super.key, required this.id, this.tag, this.onDeleted});

  static const _maxLabelWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tag = this.tag;
    final name = tag?.name ?? id;
    final color = tag == null
        ? getStringColor(id)
        : MailboxesController.colorOf(tag);

    return Chip(
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxLabelWidth),
        child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      labelStyle: theme.textTheme.labelSmall,
      backgroundColor: Color.alphaBlend(
        color.withValues(alpha: 0.22),
        theme.colorScheme.surface,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      // See AttachmentChipView: defer to the row that holds the chip.
      mouseCursor: MouseCursor.defer,
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: l.mailboxRemoveTag(name),
    );
  }
}
