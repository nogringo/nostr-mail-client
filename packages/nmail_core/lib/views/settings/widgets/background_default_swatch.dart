import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:system_theme/system_theme.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'background_thumbnail.dart';

class BackgroundDefaultSwatch extends StatelessWidget {
  const BackgroundDefaultSwatch({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = Get.find<SettingsController>();

    final systemScheme = ColorScheme.fromSeed(
      seedColor: SystemTheme.accentColor.accent,
      brightness: Theme.of(context).brightness,
    );

    return Obx(() {
      final current = settings.backgroundImage.value;
      return BackgroundThumbnail(
        label: l.settingsBackgroundDefaultLabel,
        isSelected: current == null || current.isEmpty,
        onTap: () => Get.find<BackgroundsController>().select(null),
        child: ColoredBox(color: systemScheme.primaryContainer),
      );
    });
  }
}
