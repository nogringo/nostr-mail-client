import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/color_contrast.dart';

void main() {
  const light = Color(0xFFFEF7FF);
  const dark = Color(0xFF141218);

  group('ensureContrast', () {
    test('keeps a color that already stands out', () {
      const red = Color(0xFFD50000);
      expect(ensureContrast(red, light, minRatio: 3), red);
    });

    test('darkens a pale color on a light background', () {
      const yellow = Color(0xFFF6BF26);
      final adjusted = ensureContrast(yellow, light, minRatio: 3);
      expect(contrastRatio(adjusted, light), greaterThanOrEqualTo(3));
      expect(contrastRatio(adjusted, light), lessThan(3.1));
      expect(
        HSLColor.fromColor(adjusted).hue,
        closeTo(HSLColor.fromColor(yellow).hue, 1),
      );
    });

    test('lightens a deep color on a dark background', () {
      const black = Color(0xFF000000);
      final adjusted = ensureContrast(black, dark, minRatio: 3);
      expect(contrastRatio(adjusted, dark), greaterThanOrEqualTo(3));
      expect(adjusted.computeLuminance(), greaterThan(dark.computeLuminance()));
    });

    test('turns white into a visible grey on a light background', () {
      final adjusted = ensureContrast(Colors.white, light, minRatio: 3);
      expect(contrastRatio(adjusted, light), greaterThanOrEqualTo(3));
    });
  });
}
