import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'palette_style_swatch.dart';

class PaletteStylePicker extends StatelessWidget {
  const PaletteStylePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final controller = Get.find<SettingsController>();

    return Obx(() {
      final seed = brightness == Brightness.dark
          ? controller.darkSeedColor.value
          : controller.lightSeedColor.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final style in DynamicSchemeVariant.values)
            PaletteStyleSwatch(
              scheme: ColorScheme.fromSeed(
                seedColor: seed,
                brightness: brightness,
                dynamicSchemeVariant: style,
              ),
              label: l.settingsPaletteStyleName(style.name),
              selected: controller.paletteStyle.value == style,
              onTap: () => controller.setPaletteStyle(style),
            ),
        ],
      );
    });
  }
}
