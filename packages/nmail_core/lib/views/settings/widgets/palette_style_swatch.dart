import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Previews a palette style as six wedges alternating the primary, secondary
/// and tertiary colors of the [scheme] it produces with their containers.
class PaletteStyleSwatch extends StatelessWidget {
  const PaletteStyleSwatch({
    super.key,
    required this.scheme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final ColorScheme scheme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _size = 48.0;
  static const _selectedShape = StarBorder(
    points: 8,
    innerRadiusRatio: 0.8,
    pointRounding: 0.6,
    valleyRounding: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    final wedges = [
      scheme.primary,
      scheme.primaryContainer,
      scheme.secondary,
      scheme.secondaryContainer,
      scheme.tertiary,
      scheme.tertiaryContainer,
    ];

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        excludeSemantics: true,
        child: Material(
          shape: selected ? _selectedShape : const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            decoration: BoxDecoration(
              // Hard stops turn the sweep into wedges; the first one is
              // centered on top.
              gradient: SweepGradient(
                colors: [
                  for (final color in wedges) ...[color, color],
                ],
                stops: [
                  for (var i = 0; i < wedges.length; i++) ...[
                    i / wedges.length,
                    (i + 1) / wedges.length,
                  ],
                ],
                transform: const GradientRotation(-2 * math.pi / 3),
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: SizedBox.square(
                dimension: _size,
                child: selected
                    ? Center(
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: scheme.surface,
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: scheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
