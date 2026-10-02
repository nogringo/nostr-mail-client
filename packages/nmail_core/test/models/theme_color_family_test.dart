import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/models/theme_color_family.dart';

void main() {
  test('classifies pure hues by family', () {
    final expected = {
      Color(0xFFFF0000): ThemeColorFamily.red,
      Color(0xFF8B4513): ThemeColorFamily.orange,
      Color(0xFFFF8000): ThemeColorFamily.orange,
      Color(0xFFFFFF00): ThemeColorFamily.yellow,
      Color(0xFF00FF00): ThemeColorFamily.green,
      Color(0xFF008080): ThemeColorFamily.cyan,
      Color(0xFF0000FF): ThemeColorFamily.blue,
      Color(0xFF8000FF): ThemeColorFamily.purple,
      Color(0xFFFF00FF): ThemeColorFamily.purple,
      Color(0xFFFF69B4): ThemeColorFamily.pink,
      Color(0xFF808080): ThemeColorFamily.gray,
      Color(0xFFFFFFFF): ThemeColorFamily.gray,
      Color(0xFF000000): ThemeColorFamily.gray,
    };

    expected.forEach((color, family) {
      expect(ThemeColorFamily.of(color), family, reason: '$color');
    });
  });

  test('each swatch belongs to its own family', () {
    for (final family in ThemeColorFamily.values) {
      expect(ThemeColorFamily.of(family.swatch), family);
    }
  });
}
