import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import 'background_add_button.dart';
import 'background_default_swatch.dart';
import 'background_file_thumbnail.dart';
import 'background_thumbnail.dart';

/// Saved background images, newest first, between the default color swatch and
/// the add button. Native only: web keeps a single URL.
class BackgroundGallery extends StatelessWidget {
  const BackgroundGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BackgroundsController>();

    return SizedBox(
      height: backgroundThumbnailSize,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        child: Obx(() {
          final files = controller.savedImages;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: files.length + 2,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) return const BackgroundDefaultSwatch();
              if (index == files.length + 1) return const BackgroundAddButton();
              return BackgroundFileThumbnail(file: files[index - 1]);
            },
          );
        }),
      ),
    );
  }
}
