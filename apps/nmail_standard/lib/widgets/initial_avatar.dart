import 'package:flutter/material.dart';

import 'package:nmail_core/utils/string_color.dart';

/// Circular avatar showing the first letter of [name] over a color derived
/// from the name. Used for contacts that have no email or Nostr identity to
/// key a richer avatar off.
class InitialAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialAvatar({super.key, required this.name, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final color = trimmed.isEmpty
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : getStringColor(trimmed);
    final isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        trimmed.isEmpty ? '?' : trimmed[0].toUpperCase(),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
