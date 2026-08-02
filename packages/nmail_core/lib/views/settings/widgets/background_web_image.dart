import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import '../../../models/background_preset.dart';
import 'background_add_button.dart';
import 'background_default_swatch.dart';
import 'background_grid.dart';
import 'background_preset_thumbnail.dart';
import 'background_url_thumbnail.dart';

// TODO: keep a history of pasted URLs so web gets a gallery too
class BackgroundWebImage extends StatelessWidget {
  const BackgroundWebImage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final value = settings.backgroundImage.value;
      final hasUrl = BackgroundPreset.isCustomImageValue(value);
      const presets = BackgroundPreset.all;

      return BackgroundGrid(
        children: [
          for (final preset in presets)
            BackgroundPresetThumbnail(preset: preset),
          const BackgroundDefaultSwatch(),
          if (hasUrl) BackgroundUrlThumbnail(url: value!),
          const BackgroundAddButton(),
        ],
      );
    });
  }
}
