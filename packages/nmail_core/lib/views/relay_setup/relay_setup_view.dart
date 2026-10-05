import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/widgets/controller_builder.dart';
import '../shared/app_bar_account_avatar.dart';
import 'widgets/relay_setup_missing.dart';
import 'widgets/relay_setup_searching.dart';
import 'widgets/relay_setup_unreachable.dart';

/// Post-login step for an account whose NIP-65 relay list is nowhere to be
/// found. Without it we don't know which relays to read, so the account stays
/// parked here until the list turns up. The account menu is the way out.
class RelaySetupView extends StatelessWidget {
  const RelaySetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = GetIt.I<AuthController>();
    return PopScope(
      canPop: false,
      child: ListenableBuilder(
        listenable: Listenable.merge([
          auth.activePubkey,
          auth.needsRelayListSetup,
        ]),
        builder: (context, _) {
          final pubkey = auth.publicKey;
          // Both flip just before the router leaves this screen.
          if (pubkey == null || !auth.needsRelayListSetup.value) {
            return const Scaffold();
          }
          // One controller per account: logging out here can land on another
          // account that has no list either, without leaving this route.
          return ControllerBuilder(
            key: ValueKey(pubkey),
            create: RelaySetupController.new,
            builder: (context, controller) => Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                actions: const [AppBarAccountAvatar(), SizedBox(width: 16)],
              ),
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    child: ResponsiveCenter(
                      maxWidth: 400,
                      padding: const EdgeInsets.all(24),
                      child: switch (controller.stage) {
                        RelaySetupStage.searching => RelaySetupSearching(
                          controller: controller,
                        ),
                        RelaySetupStage.unreachable => RelaySetupUnreachable(
                          controller: controller,
                        ),
                        RelaySetupStage.missing => RelaySetupMissing(
                          controller: controller,
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
