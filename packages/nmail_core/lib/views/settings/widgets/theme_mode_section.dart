import 'package:flutter/material.dart';

import 'settings_group.dart';
import 'theme_mode_tile.dart';

class ThemeModeSection extends StatelessWidget {
  const ThemeModeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      rows: [
        for (final mode in ThemeMode.values)
          (index, count) =>
              ThemeModeTile(mode: mode, index: index, count: count),
      ],
    );
  }
}
