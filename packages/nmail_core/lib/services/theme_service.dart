import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeService extends GetxService {
  static const dynamicThemeKey = 'dynamic_theme';
  static const themeColorKey = 'theme_color';
  static const paletteStyleKey = 'palette_style';
  static const backgroundSeedColorKeyPrefix = 'background_seed_color:';

  final lightColorScheme = Rxn<ColorScheme>();
  final darkColorScheme = Rxn<ColorScheme>();

  void setColorSchemes(ColorScheme? light, ColorScheme? dark) {
    lightColorScheme.value = light;
    darkColorScheme.value = dark;
  }

  void clear() {
    lightColorScheme.value = null;
    darkColorScheme.value = null;
  }
}
