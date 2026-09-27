import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_block_tile.dart';
import 'theme_color_picker.dart';

class ThemeColorTile extends StatelessWidget {
  const ThemeColorTile({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SettingsBlockTile(
      index: index,
      count: count,
      icon: Icons.format_paint_outlined,
      label: AppLocalizations.of(context).settingsThemeColor,
      child: const ThemeColorPicker(),
    );
  }
}
