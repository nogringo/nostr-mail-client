import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'layout_constants.dart';

class AccountMenuHeader extends StatelessWidget {
  const AccountMenuHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Get.find<AuthController>();
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final metadata = auth.userMetadata.value;
      final pubkey = auth.currentPubkey!;

      return Container(
        width: LayoutConstants.accountMenuWidth,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            NostrAvatar(pubkey: pubkey, metadata: metadata, radius: 32),
            const SizedBox(height: 12),
            Text(
              metadata?.getBestName() ?? getAnonName(pubkey),
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () {
                MenuController.maybeOf(context)?.close();
                context.go(AppRoutes.profile);
              },
              icon: const Icon(Icons.edit_outlined),
              label: Text(l.inboxEditProfile),
            ),
          ],
        ),
      );
    });
  }
}
