import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

class AccountMenuHeader extends StatelessWidget {
  const AccountMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final metadata = auth.userMetadata.value;
      final pubkey = auth.currentPubkey!;

      return Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            NostrAvatar(pubkey: pubkey, metadata: metadata, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                metadata?.getBestName() ?? getAnonName(pubkey),
                style: textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }
}
