import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';
import 'account_signer_label.dart';
import 'remove_account_button.dart';

class AccountTile extends StatelessWidget {
  const AccountTile({
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
    final auth = Get.find<AuthController>();

    return Obx(() {
      final isActive = auth.activePubkey.value == pubkey;
      final isBusy = auth.pendingAccountPubkey.value != null;

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: segmentedListGap / 2,
        ),
        child: ListTile(
          selected: isActive,
          tileColor: colorScheme.surfaceContainerHigh,
          selectedTileColor: colorScheme.secondaryContainer,
          selectedColor: colorScheme.onSecondaryContainer,
          shape: segmentedListShape(
            index: index,
            count: count,
            isSelected: isActive,
          ),
          leading: NostrAvatar(pubkey: pubkey, radius: 20),
          title: NostrDisplayName(pubkey: pubkey),
          subtitle: AccountSignerLabel(kind: auth.signerKindOf(pubkey)),
          trailing: RemoveAccountButton(pubkey: pubkey),
          onTap: isActive || isBusy ? null : () => auth.switchAccount(pubkey),
        ),
      );
    });
  }
}
