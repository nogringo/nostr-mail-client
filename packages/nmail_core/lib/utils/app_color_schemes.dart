import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:system_theme/system_theme.dart';

import 'package:nmail_core/services/theme_service.dart';

ColorScheme appLightColorScheme() =>
    Get.find<ThemeService>().lightColorScheme.value ??
    ColorScheme.fromSeed(seedColor: SystemTheme.accentColor.accent);

ColorScheme appDarkColorScheme() =>
    Get.find<ThemeService>().darkColorScheme.value ??
    ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Brightness.dark,
    );
