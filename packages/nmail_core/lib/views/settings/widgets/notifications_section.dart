import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'notification_account_tile.dart';

/// Notifications are subscribed per account, so a device holding several
/// accounts gets one switch each, active account first.
class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = Get.find<AuthController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      final active = auth.activePubkey.value;
      final pubkeys = [
        ?active,
        ...auth.accountPubkeys.where((pubkey) => pubkey != active),
      ];

      if (pubkeys.length < 2) {
        return SwitchListTile(
          title: Text(l.settingsEnableNotifications),
          subtitle: Text(l.settingsEnableNotificationsSubtitle),
          value: settings.notificationsEnabled.value,
          onChanged: settings.setNotificationsEnabled,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l.settingsEnableNotificationsSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final pubkey in pubkeys)
            NotificationAccountTile(key: ValueKey(pubkey), pubkey: pubkey),
        ],
      );
    });
  }
}
