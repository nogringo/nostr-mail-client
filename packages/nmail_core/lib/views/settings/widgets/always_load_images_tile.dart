import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

class AlwaysLoadImagesTile extends StatelessWidget {
  const AlwaysLoadImagesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Obx(
        () => SwitchListTile(
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: 1, count: 2),
          minTileHeight: 72,
          secondary: const Icon(Icons.image_outlined),
          title: Text(l.settingsAlwaysLoadImages),
          subtitle: Text(l.settingsAlwaysLoadImagesSubtitle),
          value: settings.alwaysLoadImages.value,
          onChanged: settings.setAlwaysLoadImages,
        ),
      ),
    );
  }
}
