import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Single-account switch, standing in for the per-account rows when there is
/// only one account to name.
class NotificationsEnabledTile extends StatelessWidget {
  const NotificationsEnabledTile({super.key});

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
          shape: segmentedListShape(index: 0, count: 1),
          minTileHeight: 72,
          secondary: const Icon(Icons.notifications_outlined),
          title: Text(l.settingsEnableNotifications),
          value: settings.notificationsEnabled.value,
          onChanged: settings.setNotificationsEnabled,
        ),
      ),
    );
  }
}
