import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// An avatar that doubles as its row's selection control: hovering it swaps the
/// avatar for a check, so the affordance stays discoverable without a separate
/// checkbox column. Every state is the same circle of the same radius, so the
/// row never shifts.
///
/// [hoveredId] is the list's shared "row under the pointer", owned by its
/// controller: keeping it in one place means only the row entered and the row
/// left rebuild.
class SelectableAvatar extends StatelessWidget {
  final String id;
  final RxnString hoveredId;
  final Widget avatar;
  final double radius;
  final bool isSelected;
  final VoidCallback? onToggle;
  final String? semanticsLabel;

  const SelectableAvatar({
    super.key,
    required this.id,
    required this.hoveredId,
    required this.avatar,
    required this.isSelected,
    this.radius = 20,
    this.onToggle,
    this.semanticsLabel,
  });

  /// The exit of the row being left can arrive after the entry of the next one,
  /// so only the row that still owns the hover may clear it.
  void _setHovered(bool hovered) {
    if (hovered) {
      hoveredId.value = id;
    } else if (hoveredId.value == id) {
      hoveredId.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticsLabel,
      button: onToggle != null,
      selected: isSelected,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: InkWell(
          onTap: onToggle,
          mouseCursor: WidgetStateMouseCursor.clickable,
          customBorder: const CircleBorder(),
          child: Obx(() {
            // Read before the branches: an Obx that returns without touching
            // its observable throws.
            final isHovered = hoveredId.value == id;
            if (isSelected) {
              return CircleAvatar(
                radius: radius,
                child: Icon(Icons.check, size: radius),
              );
            }
            if (onToggle != null && isHovered) {
              return CircleAvatar(
                radius: radius,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.check,
                  size: radius,
                  color: colorScheme.onSurfaceVariant,
                ),
              );
            }
            return avatar;
          }),
        ),
      ),
    );
  }
}
