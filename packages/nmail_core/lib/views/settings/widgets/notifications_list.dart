import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'notification_account_tile.dart';
import 'notifications_enabled_tile.dart';

/// Notifications are subscribed per account, so a device holding several
/// accounts gets one switch each, active account first.
class NotificationsList extends StatelessWidget {
  const NotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final active = auth.activePubkey.value;
      final pubkeys = [
        ?active,
        ...auth.accountPubkeys.where((pubkey) => pubkey != active),
      ];

      if (pubkeys.length < 2) return const NotificationsEnabledTile();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, pubkey) in pubkeys.indexed)
            NotificationAccountTile(
              key: ValueKey(pubkey),
              pubkey: pubkey,
              index: index,
              count: pubkeys.length,
            ),
        ],
      );
    });
  }
}
