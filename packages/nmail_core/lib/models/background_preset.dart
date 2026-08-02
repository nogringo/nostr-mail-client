import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class BackgroundPresetVariant {
  const BackgroundPresetVariant({
    required this.id,
    required this.seedColor,
    this.assetPath,
  });

  final String id;
  final Color seedColor;
  final String? assetPath;

  bool get isAsset => assetPath != null;
}

class BackgroundPreset {
  const BackgroundPreset({
    required this.id,
    required this.lightVariant,
    required this.darkVariant,
  });

  static const packageName = 'nmail_core';
  static const storagePrefix = 'preset:';
  static const systemColorStorageValue = 'system:color';
  static const defaultId = 'animated_waves';

  final String id;
  final BackgroundPresetVariant lightVariant;
  final BackgroundPresetVariant darkVariant;

  String get storageValue => '$storagePrefix$id';

  Color get lightSeedColor => lightVariant.seedColor;

  Color get darkSeedColor => darkVariant.seedColor;

  BackgroundPresetVariant variantForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkVariant : lightVariant;
  }

  static const all = [
    BackgroundPreset(
      id: 'animated_waves',
      lightVariant: BackgroundPresetVariant(
        id: 'paper_light',
        seedColor: Color(0xFFC67A60),
      ),
      darkVariant: BackgroundPresetVariant(
        id: 'midnight_inbox',
        seedColor: Color(0xFF75B5A6),
      ),
    ),
    BackgroundPreset(
      id: 'soft_gradient',
      lightVariant: BackgroundPresetVariant(
        id: 'relay_map',
        seedColor: Color(0xFFC56C62),
      ),
      darkVariant: BackgroundPresetVariant(
        id: 'dawn_sync',
        seedColor: Color(0xFF7FB4A4),
      ),
    ),
    BackgroundPreset(
      id: 'bloom_image',
      lightVariant: BackgroundPresetVariant(
        id: 'blossom_glass',
        seedColor: Color(0xFF9E8F5A),
        assetPath: 'assets/backgrounds/blossom_glass.webp',
      ),
      darkVariant: BackgroundPresetVariant(
        id: 'obsidian_bloom',
        seedColor: Color(0xFFC29A55),
        assetPath: 'assets/backgrounds/obsidian_bloom.webp',
      ),
    ),
  ];

  static BackgroundPreset? fromStorageValue(String? value) {
    if (value == null || !value.startsWith(storagePrefix)) return null;
    final id = value.substring(storagePrefix.length);
    return byId(id);
  }

  static BackgroundPreset? byId(String id) {
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  static BackgroundPreset defaultPreset() {
    return byId(defaultId)!;
  }

  static BackgroundPreset? resolve(String? value) {
    if (value == null || value.isEmpty) return defaultPreset();
    if (isSystemColorValue(value)) return null;
    return fromStorageValue(value);
  }

  static bool isSystemColorValue(String? value) {
    return value == systemColorStorageValue;
  }

  static bool isCustomImageValue(String? value) {
    return value != null &&
        value.isNotEmpty &&
        !isSystemColorValue(value) &&
        !value.startsWith(storagePrefix) &&
        fromStorageValue(value) == null;
  }

  String localizedName(AppLocalizations l) => switch (id) {
    'animated_waves' => l.backgroundPresetAnimatedWaves,
    'soft_gradient' => l.backgroundPresetSoftGradient,
    'bloom_image' => l.backgroundPresetBloomImage,
    _ => id,
  };
}
