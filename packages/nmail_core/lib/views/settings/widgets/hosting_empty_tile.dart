import 'package:flutter/material.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Placeholder row standing in for a hosting group with nothing configured.
class HostingEmptyTile extends StatelessWidget {
  const HostingEmptyTile({
    super.key,
    required this.icon,
    required this.message,
    required this.index,
    required this.count,
  });

  final IconData icon;
  final String message;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 56,
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurfaceVariant,
        leading: Icon(icon),
        title: Text(message),
      ),
    );
  }
}
