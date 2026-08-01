import 'package:flutter/material.dart';

import 'background_tile.dart';
import 'dynamic_theme_tile.dart';
import 'settings_group.dart';

class BackgroundSection extends StatelessWidget {
  const BackgroundSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      rows: [
        (index, count) => BackgroundTile(index: index, count: count),
        (index, count) => DynamicThemeTile(index: index, count: count),
      ],
    );
  }
}
