import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../../widgets/nostr_avatar.dart';
import 'account_menu.dart';
import 'layout_constants.dart';

class AppBarAccountAvatar extends StatelessWidget {
  const AppBarAccountAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = GetIt.I<AuthController>();

    return AccountMenu(
      alignmentOffset: const Offset(
        -(LayoutConstants.accountMenuWidth - 36),
        8,
      ),
      builder: (context, menuController, child) {
        return Semantics(
          label: l.inboxAccount,
          button: true,
          child: GestureDetector(
            onTap: () {
              if (menuController.isOpen) {
                menuController.close();
              } else {
                menuController.open();
              }
            },
            child: ListenableBuilder(
              listenable: Listenable.merge([
                auth.activePubkey,
                auth.userMetadata,
              ]),
              builder: (context, _) => NostrAvatar(
                pubkey: auth.currentPubkey!,
                metadata: auth.userMetadata.value,
                radius: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}
