import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

class DynamicThemeTile extends StatelessWidget {
  const DynamicThemeTile({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Obx(
        () => SwitchListTile(
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: index, count: count),
          minTileHeight: 72,
          secondary: const Icon(Icons.auto_awesome_outlined),
          title: Text(l.settingsDynamicTheme),
          subtitle: Text(l.settingsDynamicThemeSubtitle),
          value: controller.dynamicTheme.value,
          onChanged: controller.setDynamicTheme,
        ),
      ),
    );
  }
}
