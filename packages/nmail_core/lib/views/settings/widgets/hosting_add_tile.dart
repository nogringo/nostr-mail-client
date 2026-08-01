import 'package:flutter/material.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Closing row of a hosting group, carrying the group's add action.
class HostingAddTile extends StatelessWidget {
  const HostingAddTile({
    super.key,
    required this.label,
    required this.index,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int index;
  final int count;
  final VoidCallback onTap;

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
        iconColor: colorScheme.primary,
        textColor: colorScheme.primary,
        leading: const Icon(Icons.add),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}
