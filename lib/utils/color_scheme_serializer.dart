import 'dart:convert';

import 'package:flutter/material.dart';

/// Serialize a ColorScheme to JSON string
String colorSchemeToJson(ColorScheme scheme) {
  return jsonEncode({
    'primary': scheme.primary.toARGB32(),
    'onPrimary': scheme.onPrimary.toARGB32(),
    'primaryContainer': scheme.primaryContainer.toARGB32(),
    'onPrimaryContainer': scheme.onPrimaryContainer.toARGB32(),
    'secondary': scheme.secondary.toARGB32(),
    'onSecondary': scheme.onSecondary.toARGB32(),
    'secondaryContainer': scheme.secondaryContainer.toARGB32(),
    'onSecondaryContainer': scheme.onSecondaryContainer.toARGB32(),
    'tertiary': scheme.tertiary.toARGB32(),
    'onTertiary': scheme.onTertiary.toARGB32(),
    'tertiaryContainer': scheme.tertiaryContainer.toARGB32(),
    'onTertiaryContainer': scheme.onTertiaryContainer.toARGB32(),
    'error': scheme.error.toARGB32(),
    'onError': scheme.onError.toARGB32(),
    'errorContainer': scheme.errorContainer.toARGB32(),
    'onErrorContainer': scheme.onErrorContainer.toARGB32(),
    'surface': scheme.surface.toARGB32(),
    'onSurface': scheme.onSurface.toARGB32(),
    'onSurfaceVariant': scheme.onSurfaceVariant.toARGB32(),
    'outline': scheme.outline.toARGB32(),
    'outlineVariant': scheme.outlineVariant.toARGB32(),
    'shadow': scheme.shadow.toARGB32(),
    'scrim': scheme.scrim.toARGB32(),
    'inverseSurface': scheme.inverseSurface.toARGB32(),
    'onInverseSurface': scheme.onInverseSurface.toARGB32(),
    'inversePrimary': scheme.inversePrimary.toARGB32(),
    'surfaceTint': scheme.surfaceTint.toARGB32(),
    'brightness': scheme.brightness.index,
  });
}

/// Deserialize a JSON string to ColorScheme
ColorScheme? colorSchemeFromJson(String json) {
  try {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ColorScheme(
      primary: Color(map['primary'] as int),
      onPrimary: Color(map['onPrimary'] as int),
      primaryContainer: Color(map['primaryContainer'] as int),
      onPrimaryContainer: Color(map['onPrimaryContainer'] as int),
      secondary: Color(map['secondary'] as int),
      onSecondary: Color(map['onSecondary'] as int),
      secondaryContainer: Color(map['secondaryContainer'] as int),
      onSecondaryContainer: Color(map['onSecondaryContainer'] as int),
      tertiary: Color(map['tertiary'] as int),
      onTertiary: Color(map['onTertiary'] as int),
      tertiaryContainer: Color(map['tertiaryContainer'] as int),
      onTertiaryContainer: Color(map['onTertiaryContainer'] as int),
      error: Color(map['error'] as int),
      onError: Color(map['onError'] as int),
      errorContainer: Color(map['errorContainer'] as int),
      onErrorContainer: Color(map['onErrorContainer'] as int),
      surface: Color(map['surface'] as int),
      onSurface: Color(map['onSurface'] as int),
      onSurfaceVariant: Color(map['onSurfaceVariant'] as int),
      outline: Color(map['outline'] as int),
      outlineVariant: Color(map['outlineVariant'] as int),
      shadow: Color(map['shadow'] as int),
      scrim: Color(map['scrim'] as int),
      inverseSurface: Color(map['inverseSurface'] as int),
      onInverseSurface: Color(map['onInverseSurface'] as int),
      inversePrimary: Color(map['inversePrimary'] as int),
      surfaceTint: Color(map['surfaceTint'] as int),
      brightness: Brightness.values[map['brightness'] as int],
    );
  } catch (e) {
    return null;
  }
}
