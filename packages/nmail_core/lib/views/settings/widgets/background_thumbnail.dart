import 'package:flutter/material.dart';

/// One tile of the background gallery. The current background is outlined so
/// the selection survives on top of any image.
class BackgroundThumbnail extends StatelessWidget {
  const BackgroundThumbnail({
    super.key,
    required this.label,
    required this.child,
    this.isSelected,
    this.badge,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final Widget child;

  /// Null for tiles that are not backgrounds themselves, like the add button.
  final bool? isSelected;
  final Widget? badge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: isSelected,
      child: MouseRegion(
        cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: SizedBox.expand(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: child,
                      ),
                      if (isSelected ?? false)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                      if (badge != null)
                        PositionedDirectional(top: 4, end: 4, child: badge!),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ?? false
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ?? false
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
