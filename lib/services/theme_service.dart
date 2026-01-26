import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/color_scheme_serializer.dart';
import 'storage_service.dart';

class ThemeService extends GetxService {
  static const colorSchemeKeyLight = 'color_scheme_light';
  static const colorSchemeKeyDark = 'color_scheme_dark';
  static const dynamicThemeKey = 'dynamic_theme';

  final lightColorScheme = Rxn<ColorScheme>();
  final darkColorScheme = Rxn<ColorScheme>();

  Future<ThemeService> init() async {
    final storageService = Get.find<StorageService>();

    final dynamicThemeEnabled =
        await storageService.getSetting<bool>(dynamicThemeKey) ?? false;

    if (dynamicThemeEnabled) {
      final [savedLightScheme, savedDarkScheme] = await Future.wait([
        storageService.getSetting<String>(colorSchemeKeyLight),
        storageService.getSetting<String>(colorSchemeKeyDark),
      ]);

      if (savedLightScheme != null) {
        lightColorScheme.value = colorSchemeFromJson(savedLightScheme);
      }
      if (savedDarkScheme != null) {
        darkColorScheme.value = colorSchemeFromJson(savedDarkScheme);
      }
    }

    return this;
  }

  void setColorSchemes(ColorScheme? light, ColorScheme? dark) {
    lightColorScheme.value = light;
    darkColorScheme.value = dark;
  }

  void clear() {
    lightColorScheme.value = null;
    darkColorScheme.value = null;
  }
}
