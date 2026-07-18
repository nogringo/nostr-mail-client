import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

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
      leadingIcon: _AccountAvatar(pubkey: pubkey, radius: 12),
      onPressed: () => auth.switchAccount(pubkey),
      child: _AccountLabel(pubkey: pubkey),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({required this.pubkey, required this.radius});

  final String pubkey;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metadata = Get.find<MetadataService>().of(pubkey).value;
      return NostrAvatar(pubkey: pubkey, metadata: metadata, radius: radius);
    });
  }
}

class _AccountLabel extends StatelessWidget {
  const _AccountLabel({required this.pubkey});

  final String pubkey;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metadata = Get.find<MetadataService>().of(pubkey).value;
      return Text(
        metadata?.getBestName() ?? getAnonName(pubkey),
        overflow: TextOverflow.ellipsis,
      );
    });
  }
}
