import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// One relay, server or bridge inside a hosting group. Removals are staged, so
/// a row marked for deletion keeps its place struck through until the section
/// is saved.
class HostingResourceTile extends StatelessWidget {
  const HostingResourceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.count,
    required this.isMarkedForDeletion,
    required this.removeTooltip,
    required this.onToggleDeletion,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final int count;
  final bool isMarkedForDeletion;
  final String removeTooltip;
  final VoidCallback onToggleDeletion;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final staged = isMarkedForDeletion ? theme.disabledColor : null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: theme.colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: subtitle == null ? 56 : 72,
        iconColor: staged,
        textColor: staged,
        leading: Icon(icon),
        title: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: isMarkedForDeletion
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: IconButton(
          icon: Icon(isMarkedForDeletion ? Icons.undo : Icons.close),
          tooltip: isMarkedForDeletion ? l.actionUndo : removeTooltip,
          onPressed: onToggleDeletion,
        ),
        onTap: isMarkedForDeletion ? null : onTap,
      ),
    );
  }
}
