import 'package:flutter/material.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Settings row that acts in place instead of opening a sub page.
class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.index,
    required this.count,
    required this.onTap,
    this.subtitle,
    this.isBusy = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final int index;
  final int count;
  final VoidCallback? onTap;

  /// Shows a spinner in place of [icon] while the action runs.
  final bool isBusy;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isDestructive ? colorScheme.error : null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: index, count: count),
          minTileHeight: 56,
          iconColor: foreground,
          textColor: foreground,
          leading: isBusy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          enabled: onTap != null || isBusy,
          onTap: onTap,
        ),
      ),
    );
  }
}
