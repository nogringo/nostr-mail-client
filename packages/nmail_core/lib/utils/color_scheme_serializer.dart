import 'dart:convert';

import 'package:flutter/material.dart';

/// Serialize a ColorScheme to JSON string
String colorSchemeToJson(ColorScheme scheme) {
  return jsonEncode({
    'brightness': scheme.brightness.index,
    'primary': scheme.primary.toARGB32(),
    'onPrimary': scheme.onPrimary.toARGB32(),
    'primaryContainer': scheme.primaryContainer.toARGB32(),
    'onPrimaryContainer': scheme.onPrimaryContainer.toARGB32(),
    'primaryFixed': scheme.primaryFixed.toARGB32(),
    'primaryFixedDim': scheme.primaryFixedDim.toARGB32(),
    'onPrimaryFixed': scheme.onPrimaryFixed.toARGB32(),
    'onPrimaryFixedVariant': scheme.onPrimaryFixedVariant.toARGB32(),
    'secondary': scheme.secondary.toARGB32(),
    'onSecondary': scheme.onSecondary.toARGB32(),
    'secondaryContainer': scheme.secondaryContainer.toARGB32(),
    'onSecondaryContainer': scheme.onSecondaryContainer.toARGB32(),
    'secondaryFixed': scheme.secondaryFixed.toARGB32(),
    'secondaryFixedDim': scheme.secondaryFixedDim.toARGB32(),
    'onSecondaryFixed': scheme.onSecondaryFixed.toARGB32(),
    'onSecondaryFixedVariant': scheme.onSecondaryFixedVariant.toARGB32(),
    'tertiary': scheme.tertiary.toARGB32(),
    'onTertiary': scheme.onTertiary.toARGB32(),
    'tertiaryContainer': scheme.tertiaryContainer.toARGB32(),
    'onTertiaryContainer': scheme.onTertiaryContainer.toARGB32(),
    'tertiaryFixed': scheme.tertiaryFixed.toARGB32(),
    'tertiaryFixedDim': scheme.tertiaryFixedDim.toARGB32(),
    'onTertiaryFixed': scheme.onTertiaryFixed.toARGB32(),
    'onTertiaryFixedVariant': scheme.onTertiaryFixedVariant.toARGB32(),
    'error': scheme.error.toARGB32(),
    'onError': scheme.onError.toARGB32(),
    'errorContainer': scheme.errorContainer.toARGB32(),
    'onErrorContainer': scheme.onErrorContainer.toARGB32(),
    'surface': scheme.surface.toARGB32(),
    'onSurface': scheme.onSurface.toARGB32(),
    'surfaceDim': scheme.surfaceDim.toARGB32(),
    'surfaceBright': scheme.surfaceBright.toARGB32(),
    'surfaceContainerLowest': scheme.surfaceContainerLowest.toARGB32(),
    'surfaceContainerLow': scheme.surfaceContainerLow.toARGB32(),
    'surfaceContainer': scheme.surfaceContainer.toARGB32(),
    'surfaceContainerHigh': scheme.surfaceContainerHigh.toARGB32(),
    'surfaceContainerHighest': scheme.surfaceContainerHighest.toARGB32(),
    'onSurfaceVariant': scheme.onSurfaceVariant.toARGB32(),
    'outline': scheme.outline.toARGB32(),
    'outlineVariant': scheme.outlineVariant.toARGB32(),
    'shadow': scheme.shadow.toARGB32(),
    'scrim': scheme.scrim.toARGB32(),
    'inverseSurface': scheme.inverseSurface.toARGB32(),
    'onInverseSurface': scheme.onInverseSurface.toARGB32(),
    'inversePrimary': scheme.inversePrimary.toARGB32(),
    'surfaceTint': scheme.surfaceTint.toARGB32(),
  });
}

/// Deserialize a JSON string to ColorScheme
ColorScheme? colorSchemeFromJson(String json) {
  try {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final brightness = Brightness.values[map['brightness'] as int];
    final primary = Color(map['primary'] as int);

    Color? role(String key) => map[key] is int ? Color(map[key] as int) : null;

    // Roles missing from the JSON keep the seeded palette's value: the raw
    // ColorScheme constructor would instead collapse them onto `surface`, so
    // schemes saved before every role was serialized lost their containers.
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      onPrimary: role('onPrimary'),
      primaryContainer: role('primaryContainer'),
      onPrimaryContainer: role('onPrimaryContainer'),
      primaryFixed: role('primaryFixed'),
      primaryFixedDim: role('primaryFixedDim'),
      onPrimaryFixed: role('onPrimaryFixed'),
      onPrimaryFixedVariant: role('onPrimaryFixedVariant'),
      secondary: role('secondary'),
      onSecondary: role('onSecondary'),
      secondaryContainer: role('secondaryContainer'),
      onSecondaryContainer: role('onSecondaryContainer'),
      secondaryFixed: role('secondaryFixed'),
      secondaryFixedDim: role('secondaryFixedDim'),
      onSecondaryFixed: role('onSecondaryFixed'),
      onSecondaryFixedVariant: role('onSecondaryFixedVariant'),
      tertiary: role('tertiary'),
      onTertiary: role('onTertiary'),
      tertiaryContainer: role('tertiaryContainer'),
      onTertiaryContainer: role('onTertiaryContainer'),
      tertiaryFixed: role('tertiaryFixed'),
      tertiaryFixedDim: role('tertiaryFixedDim'),
      onTertiaryFixed: role('onTertiaryFixed'),
      onTertiaryFixedVariant: role('onTertiaryFixedVariant'),
      error: role('error'),
      onError: role('onError'),
      errorContainer: role('errorContainer'),
      onErrorContainer: role('onErrorContainer'),
      surface: role('surface'),
      onSurface: role('onSurface'),
      surfaceDim: role('surfaceDim'),
      surfaceBright: role('surfaceBright'),
      surfaceContainerLowest: role('surfaceContainerLowest'),
      surfaceContainerLow: role('surfaceContainerLow'),
      surfaceContainer: role('surfaceContainer'),
      surfaceContainerHigh: role('surfaceContainerHigh'),
      surfaceContainerHighest: role('surfaceContainerHighest'),
      onSurfaceVariant: role('onSurfaceVariant'),
      outline: role('outline'),
      outlineVariant: role('outlineVariant'),
      shadow: role('shadow'),
      scrim: role('scrim'),
      inverseSurface: role('inverseSurface'),
      onInverseSurface: role('onInverseSurface'),
      inversePrimary: role('inversePrimary'),
      surfaceTint: role('surfaceTint'),
    );
  } catch (e) {
    return null;
  }
}
