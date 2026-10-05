import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static const dynamicThemeKey = 'dynamic_theme';
  static const themeColorKey = 'theme_color';
  static const paletteStyleKey = 'palette_style';
  static const backgroundSeedColorKeyPrefix = 'background_seed_color:';
  static const communityThemeKey = 'community_theme';

  ColorScheme? _lightColorScheme;
  ColorScheme? _darkColorScheme;

  ColorScheme? get lightColorScheme => _lightColorScheme;
  ColorScheme? get darkColorScheme => _darkColorScheme;

  void setColorSchemes(ColorScheme? light, ColorScheme? dark) {
    if (light == _lightColorScheme && dark == _darkColorScheme) return;
    _lightColorScheme = light;
    _darkColorScheme = dark;
    notifyListeners();
  }

  void clear() => setColorSchemes(null, null);
}
