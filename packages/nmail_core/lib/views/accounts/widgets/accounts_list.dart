import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'account_tile.dart';
import 'add_account_tile.dart';

class AccountsList extends StatelessWidget {
  const AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final active = auth.activePubkey.value;
      final pubkeys = [
        ?active,
        ...auth.accountPubkeys.where((pubkey) => pubkey != active),
      ];

      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final (index, pubkey) in pubkeys.indexed)
            AccountTile(
              key: ValueKey(pubkey),
              pubkey: pubkey,
              index: index,
              count: pubkeys.length,
            ),
          const SizedBox(height: 12),
          const AddAccountTile(),
        ],
      );
    });
  }
}
