import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';

class AccountSwitcherMenuSection extends StatelessWidget {
  const AccountSwitcherMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      final otherPubkeys = auth.otherAccountPubkeys;
      if (otherPubkeys.isEmpty) return const SizedBox.shrink();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final pubkey in otherPubkeys) _AccountMenuItem(pubkey: pubkey),
        ],
      );
    });
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({required this.pubkey});

  final String pubkey;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return MenuItemButton(
      leadingIcon: NostrAvatar(pubkey: pubkey, radius: 12),
      onPressed: () => auth.switchAccount(pubkey),
      child: NostrDisplayName(pubkey: pubkey),
    );
  }
}
