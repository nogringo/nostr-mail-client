import 'package:flutter/material.dart';

/// A miniature of the wide layout in [colorScheme], over [background], which
/// covers the whole preview.
class CommunityThemePreview extends StatelessWidget {
  const CommunityThemePreview({
    super.key,
    required this.colorScheme,
    this.background,
  });

  final ColorScheme colorScheme;
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: colorScheme.primaryContainer),
        ?background,
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: ColoredBox(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          _Line(color: colorScheme.primary, height: 9),
                          _Line(
                            color: colorScheme.secondaryContainer,
                            height: 7,
                          ),
                          _Line(
                            color: colorScheme.onSurfaceVariant,
                            widthFactor: 0.7,
                          ),
                          _Line(
                            color: colorScheme.onSurfaceVariant,
                            widthFactor: 0.55,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ColoredBox(
                    color: colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 5,
                        children: [
                          _Line(
                            color: colorScheme.onSurface,
                            widthFactor: 0.6,
                            height: 5,
                          ),
                          _Line(
                            color: colorScheme.onSurfaceVariant,
                            widthFactor: 0.9,
                          ),
                          _Line(
                            color: colorScheme.onSurfaceVariant,
                            widthFactor: 0.75,
                          ),
                          _Line(
                            color: colorScheme.onSurfaceVariant,
                            widthFactor: 0.85,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color, this.widthFactor = 1, this.height = 3});

  final Color color;
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color,
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}
