import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/settings_controller.dart';
import 'background_tile.dart';
import 'dynamic_theme_tile.dart';
import 'palette_style_tile.dart';
import 'settings_group.dart';
import 'theme_color_tile.dart';

class BackgroundSection extends StatelessWidget {
  const BackgroundSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<SettingsController>();

    return ValueListenableBuilder(
      valueListenable: controller.dynamicTheme,
      builder: (context, dynamicTheme, _) => SettingsGroup(
        rows: [
          (index, count) => BackgroundTile(index: index, count: count),
          (index, count) => DynamicThemeTile(index: index, count: count),
          if (!dynamicTheme)
            (index, count) => ThemeColorTile(index: index, count: count),
          (index, count) => PaletteStyleTile(index: index, count: count),
        ],
      ),
    );
  }
}
