import 'package:flutter/material.dart';

/// Icon plus title on their own line, aligned like a ListTile, for settings
/// blocks whose control sits underneath instead of on the trailing edge.
class SettingsTileLabel extends StatelessWidget {
  const SettingsTileLabel({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40, child: Icon(icon)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
