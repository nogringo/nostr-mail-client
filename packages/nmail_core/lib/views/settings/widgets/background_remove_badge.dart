import 'package:flutter/material.dart';

/// Close button pinned on a background thumbnail. Fixed scrim colors: it sits
/// on arbitrary images, where theme colors would be unreadable.
class BackgroundRemoveBadge extends StatelessWidget {
  const BackgroundRemoveBadge({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
