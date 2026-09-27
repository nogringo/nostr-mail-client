import 'package:flutter/material.dart';

/// Icon plus title on their own line, aligned like a ListTile, for settings
/// blocks whose control sits underneath instead of on the trailing edge.
class SettingsTileLabel extends StatelessWidget {
  const SettingsTileLabel({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;

    return Row(
      children: [
        SizedBox(width: 40, child: Icon(icon)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyLarge),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
