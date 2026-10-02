import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Hue family of a theme seed. Names are `colorName` keys.
enum ThemeColorFamily {
  red(Color(0xFFD50000)),
  orange(Color(0xFFFB8C00)),
  yellow(Color(0xFFF6BF26)),
  green(Color(0xFF33B679)),
  cyan(Color(0xFF00ACC1)),
  blue(Color(0xFF3F51B5)),
  purple(Color(0xFF8E24AA)),
  pink(Color(0xFFD81B60)),
  gray(Color(0xFF757575));

  const ThemeColorFamily(this.swatch);

  final Color swatch;

  /// Bounds are on the HCT hue, where perceived hues are evenly spread.
  static ThemeColorFamily of(Color color) {
    final hct = Hct.fromInt(color.toARGB32());
    if (hct.chroma < 5) return gray;

    final hue = hct.hue;
    if (hue < 12) return pink;
    if (hue < 40) return red;
    if (hue < 75) return orange;
    if (hue < 125) return yellow;
    if (hue < 180) return green;
    if (hue < 235) return cyan;
    if (hue < 295) return blue;
    if (hue < 345) return purple;
    return pink;
  }
}
