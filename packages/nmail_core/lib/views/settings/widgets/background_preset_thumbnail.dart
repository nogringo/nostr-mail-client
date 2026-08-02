import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/backgrounds_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/widgets/background_preset_visual.dart';
import 'background_thumbnail.dart';

class BackgroundPresetThumbnail extends StatelessWidget {
  const BackgroundPresetThumbnail({super.key, required this.preset});

  final BackgroundPreset preset;

  @override
  Widget build(BuildContext context) {
    final label = preset.localizedName(AppLocalizations.of(context));
    final brightness = Theme.of(context).brightness;
    final settings = Get.find<SettingsController>();
    final controller = Get.find<BackgroundsController>();

    return Obx(
      () => BackgroundThumbnail(
        label: label,
        isSelected:
            BackgroundPreset.resolve(settings.backgroundImage.value) == preset,
        onTap: () => controller.select(preset.storageValue),
        child: BackgroundPresetVisual(
          variant: preset.variantForBrightness(brightness),
          animate: false,
        ),
      ),
    );
  }
}
