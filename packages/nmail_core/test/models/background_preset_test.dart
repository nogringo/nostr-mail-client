import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/models/background_preset.dart';

void main() {
  test('BackgroundPreset exposes three bundled presets', () {
    expect(BackgroundPreset.all, hasLength(3));
    expect(BackgroundPreset.all.map((preset) => preset.id), [
      'animated_waves',
      'soft_gradient',
      'bloom_image',
    ]);
  });

  test('BackgroundPreset resolves stored preset values', () {
    final preset = BackgroundPreset.all.first;

    expect(
      BackgroundPreset.fromStorageValue(preset.storageValue),
      same(preset),
    );
    expect(BackgroundPreset.fromStorageValue(null), isNull);
    expect(BackgroundPreset.fromStorageValue('file.png'), isNull);
    expect(BackgroundPreset.fromStorageValue('preset:missing'), isNull);
  });

  test('BackgroundPreset only resolves selectable preset ids', () {
    expect(BackgroundPreset.fromStorageValue('preset:paper_light'), isNull);
    expect(BackgroundPreset.fromStorageValue('preset:midnight_inbox'), isNull);
    expect(BackgroundPreset.fromStorageValue('preset:relay_map'), isNull);
    expect(BackgroundPreset.fromStorageValue('preset:dawn_sync'), isNull);
    expect(BackgroundPreset.fromStorageValue('preset:blossom_glass'), isNull);
    expect(BackgroundPreset.fromStorageValue('preset:obsidian_bloom'), isNull);
  });

  test('BackgroundPreset resolves the animated default for empty values', () {
    expect(BackgroundPreset.resolve(null)?.id, BackgroundPreset.defaultId);
    expect(BackgroundPreset.resolve('')?.id, BackgroundPreset.defaultId);
  });

  test(
    'BackgroundPreset keeps system color separate from presets and images',
    () {
      expect(
        BackgroundPreset.resolve(BackgroundPreset.systemColorStorageValue),
        isNull,
      );
      expect(
        BackgroundPreset.isCustomImageValue(
          BackgroundPreset.systemColorStorageValue,
        ),
        isFalse,
      );
      expect(BackgroundPreset.isCustomImageValue('preset:missing'), isFalse);
      expect(
        BackgroundPreset.isCustomImageValue('/tmp/background.png'),
        isTrue,
      );
    },
  );

  test('BackgroundPreset variants carry colors and assets', () {
    final animated = BackgroundPreset.fromStorageValue(
      'preset:animated_waves',
    )!;
    final bloom = BackgroundPreset.fromStorageValue('preset:bloom_image')!;

    expect(animated.variantForBrightness(Brightness.light).id, 'paper_light');
    expect(animated.variantForBrightness(Brightness.dark).id, 'midnight_inbox');
    expect(animated.lightSeedColor, isNot(animated.darkSeedColor));
    expect(bloom.lightVariant.assetPath, endsWith('blossom_glass.webp'));
    expect(bloom.darkVariant.assetPath, endsWith('obsidian_bloom.webp'));
  });
}
