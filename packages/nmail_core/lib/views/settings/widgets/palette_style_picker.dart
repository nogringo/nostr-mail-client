import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'palette_style_swatch.dart';

class PaletteStylePicker extends StatelessWidget {
  const PaletteStylePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final controller = GetIt.I<SettingsController>();

    final seedColor = brightness == Brightness.dark
        ? controller.darkSeedColor
        : controller.lightSeedColor;

    return ListenableBuilder(
      listenable: Listenable.merge([seedColor, controller.paletteStyle]),
      builder: (context, _) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final style in DynamicSchemeVariant.values)
            PaletteStyleSwatch(
              scheme: ColorScheme.fromSeed(
                seedColor: seedColor.value,
                brightness: brightness,
                dynamicSchemeVariant: style,
              ),
              label: l.settingsPaletteStyleName(style.name),
              selected: controller.paletteStyle.value == style,
              onTap: () => controller.setPaletteStyle(style),
            ),
        ],
      ),
    );
  }
}
