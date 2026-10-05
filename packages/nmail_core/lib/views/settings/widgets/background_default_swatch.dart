import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:system_theme/system_theme.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'background_thumbnail.dart';

class BackgroundDefaultSwatch extends StatelessWidget {
  const BackgroundDefaultSwatch({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = GetIt.I<SettingsController>();

    final brightness = Theme.of(context).brightness;

    return ListenableBuilder(
      listenable: Listenable.merge([
        settings.backgroundImage,
        settings.paletteStyle,
      ]),
      builder: (context, _) {
        final current = settings.backgroundImage.value;
        final systemScheme = ColorScheme.fromSeed(
          seedColor: SystemTheme.accentColor.accent,
          brightness: brightness,
          dynamicSchemeVariant: settings.paletteStyle.value,
        );
        return BackgroundThumbnail(
          label: l.settingsBackgroundDefaultLabel,
          isSelected: BackgroundPreset.isSystemColorValue(current),
          onTap: () => GetIt.I<BackgroundsController>().select(
            BackgroundPreset.systemColorStorageValue,
          ),
          child: ColoredBox(color: systemScheme.primaryContainer),
        );
      },
    );
  }
}
