import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';

class NotificationAccountTile extends StatelessWidget {
  const NotificationAccountTile({super.key, required this.pubkey});

  final String pubkey;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Obx(
      () => SwitchListTile(
        secondary: NostrAvatar(pubkey: pubkey),
        title: NostrDisplayName(pubkey: pubkey),
        value: settings.notificationsByAccount[pubkey] ?? false,
        onChanged: (value) =>
            settings.setNotificationsEnabledFor(pubkey, value),
      ),
    );
  }
}
