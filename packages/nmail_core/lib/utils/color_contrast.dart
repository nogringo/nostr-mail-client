import 'dart:math';

import 'package:flutter/material.dart';

double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

/// [color] with its lightness moved away from [background] just enough to
/// reach [minRatio], keeping its hue and saturation.
Color ensureContrast(
  Color color,
  Color background, {
  required double minRatio,
}) {
  if (contrastRatio(color, background) >= minRatio) return color;
  final hsl = HSLColor.fromColor(color);
  final darken =
      ThemeData.estimateBrightnessForColor(background) == Brightness.light;
  var failing = hsl.lightness;
  var passing = darken ? 0.0 : 1.0;
  for (var i = 0; i < 16; i++) {
    final mid = (failing + passing) / 2;
    if (contrastRatio(hsl.withLightness(mid).toColor(), background) >=
        minRatio) {
      passing = mid;
    } else {
      failing = mid;
    }
  }
  return hsl.withLightness(passing).toColor().withValues(alpha: color.a);
}
