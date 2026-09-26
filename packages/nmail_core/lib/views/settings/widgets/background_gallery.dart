import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../models/background_preset.dart';
import 'background_add_button.dart';
import 'background_default_swatch.dart';
import 'background_grid.dart';
import 'background_image_thumbnail.dart';
import 'background_preset_thumbnail.dart';

/// Saved background images, newest first, after the bundled presets and system
/// color swatch.
class BackgroundGallery extends StatelessWidget {
  const BackgroundGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BackgroundsController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final images = controller.savedImages;
      final current = settings.backgroundImage.value;
      const presets = BackgroundPreset.all;

      return BackgroundGrid(
        children: [
          for (final preset in presets)
            BackgroundPresetThumbnail(preset: preset),
          const BackgroundDefaultSwatch(),
          // A URL saved by older web versions is not in the gallery.
          if (BackgroundPreset.isCustomImageValue(current) &&
              !images.contains(current))
            BackgroundImageThumbnail(value: current!),
          for (final image in images) BackgroundImageThumbnail(value: image),
          const BackgroundAddButton(),
        ],
      );
    });
  }
}
