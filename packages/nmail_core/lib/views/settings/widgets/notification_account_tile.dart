import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';

class NotificationAccountTile extends StatelessWidget {
  const NotificationAccountTile({
    super.key,
    required this.pubkey,
    required this.index,
    required this.count,
  });

  final String pubkey;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
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
          shape: segmentedListShape(index: index, count: count),
          minTileHeight: 72,
          secondary: NostrAvatar(pubkey: pubkey),
          title: NostrDisplayName(pubkey: pubkey),
          value: settings.notificationsByAccount[pubkey] ?? false,
          onChanged: (value) =>
              settings.setNotificationsEnabledFor(pubkey, value),
        ),
      ),
    );
  }
}
