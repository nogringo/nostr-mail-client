import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_tile_label.dart';

class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<SettingsController>();

    return Obx(() {
      final mode = controller.themeMode.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTileLabel(
              icon: switch (mode) {
                ThemeMode.system => Icons.brightness_auto,
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
              },
              label: l.settingsTheme,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  for (final (value, label) in [
                    (ThemeMode.system, l.settingsThemeAuto),
                    (ThemeMode.light, l.settingsThemeLight),
                    (ThemeMode.dark, l.settingsThemeDark),
                  ])
                    ButtonSegment(
                      value: value,
                      label: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
                selected: {mode},
                onSelectionChanged: (selected) =>
                    controller.setThemeMode(selected.first),
              ),
            ),
          ],
        ),
      );
    });
  }
}
