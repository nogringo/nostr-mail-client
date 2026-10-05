import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:system_theme/system_theme.dart';

import 'package:nmail_core/services/theme_service.dart';

ColorScheme appLightColorScheme() =>
    GetIt.I<ThemeService>().lightColorScheme ??
    ColorScheme.fromSeed(seedColor: SystemTheme.accentColor.accent);

ColorScheme appDarkColorScheme() =>
    GetIt.I<ThemeService>().darkColorScheme ??
    ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Brightness.dark,
    );
