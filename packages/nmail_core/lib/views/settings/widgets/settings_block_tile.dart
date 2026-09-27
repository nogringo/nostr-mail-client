import 'package:flutter/material.dart';

import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'settings_tile_label.dart';

/// Segmented row whose control sits under its label, aligned with the label
/// text.
class SettingsBlockTile extends StatelessWidget {
  const SettingsBlockTile({
    super.key,
    required this.index,
    required this.count,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.child,
  });

  final int index;
  final int count;
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              SettingsTileLabel(icon: icon, label: label, subtitle: subtitle),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 56),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
