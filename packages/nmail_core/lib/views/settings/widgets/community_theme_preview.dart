import 'package:flutter/material.dart';

import 'package:nmail_core/models/community_theme.dart';

/// A miniature of the wide layout in the colors the theme would produce.
class CommunityThemePreview extends StatelessWidget {
  const CommunityThemePreview({super.key, required this.theme});

  final CommunityTheme theme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final imageUrl = theme.backgroundImageUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: colorScheme.primaryContainer),
        if (imageUrl != null)
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            cacheWidth: 480,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
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
