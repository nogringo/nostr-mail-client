import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import 'background_add_button.dart';
import 'background_default_swatch.dart';
import 'background_thumbnail.dart';
import 'background_url_thumbnail.dart';

// TODO: keep a history of pasted URLs so web gets a gallery too
class BackgroundWebImage extends StatelessWidget {
  const BackgroundWebImage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return SizedBox(
      height: backgroundThumbnailSize,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          final url = settings.backgroundImage.value;
          return Row(
            children: [
              const BackgroundDefaultSwatch(),
              if (url != null && url.isNotEmpty) ...[
                const SizedBox(width: 8),
                BackgroundUrlThumbnail(url: url),
              ],
              const SizedBox(width: 8),
              const BackgroundAddButton(),
            ],
          );
        }),
      ),
    );
  }
}
