import 'package:flutter/material.dart';

/// Widget displaying a colored dot indicator for unread emails
class UnreadIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const UnreadIndicator({super.key, this.color, this.size = 8.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
