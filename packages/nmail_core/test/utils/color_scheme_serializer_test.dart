import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/color_scheme_serializer.dart';

void main() {
  group('Color scheme serializer', () {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    );

    test('round trips every color role', () {
      final restored = colorSchemeFromJson(colorSchemeToJson(scheme))!;

      expect(colorSchemeToJson(restored), colorSchemeToJson(scheme));
    });

    test('keeps the surface containers distinct from the surface', () {
      final restored = colorSchemeFromJson(colorSchemeToJson(scheme))!;

      expect(restored.surfaceContainerHigh, isNot(restored.surface));
      expect(restored.surfaceContainerLow, isNot(restored.surface));
    });

    test('rebuilds the roles missing from a legacy payload', () {
      final legacy =
          jsonDecode(colorSchemeToJson(scheme)) as Map<String, dynamic>
            ..removeWhere((key, _) => key.startsWith('surfaceContainer'));

      final restored = colorSchemeFromJson(jsonEncode(legacy))!;

      expect(restored.primary, scheme.primary);
      expect(restored.surfaceContainerHigh, isNot(restored.surface));
    });

    test('returns null for malformed payloads', () {
      expect(colorSchemeFromJson('not json'), isNull);
      expect(colorSchemeFromJson('{"primary": 1}'), isNull);
    });
  });
}
