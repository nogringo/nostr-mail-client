import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../models/background_preset.dart';
import 'background_add_button.dart';
import 'background_default_swatch.dart';
import 'background_file_thumbnail.dart';
import 'background_grid.dart';
import 'background_preset_thumbnail.dart';

/// Saved background images, newest first, after the bundled presets and system
/// color swatch. Native only: web keeps a single URL.
class BackgroundGallery extends StatelessWidget {
  const BackgroundGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BackgroundsController>();

    return Obx(() {
      final files = controller.savedImages;
      // TODO: Deduplicate this built-in choices order with BackgroundWebImage.
      const presets = BackgroundPreset.all;

      return BackgroundGrid(
        children: [
          for (final preset in presets)
            BackgroundPresetThumbnail(preset: preset),
          const BackgroundDefaultSwatch(),
          for (final file in files) BackgroundFileThumbnail(file: file),
          const BackgroundAddButton(),
        ],
      );
    });
  }
}
