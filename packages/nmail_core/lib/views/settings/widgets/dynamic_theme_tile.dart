import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class DynamicThemeTile extends StatelessWidget {
  const DynamicThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<SettingsController>();

    return Obx(
      () => SwitchListTile(
        secondary: const Icon(Icons.auto_awesome_outlined),
        title: Text(l.settingsDynamicTheme),
        subtitle: Text(l.settingsDynamicThemeSubtitle),
        value: controller.dynamicTheme.value,
        onChanged: controller.setDynamicTheme,
      ),
    );
  }
}
