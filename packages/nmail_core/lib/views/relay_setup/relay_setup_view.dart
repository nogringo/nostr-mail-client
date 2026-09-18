import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/relay_setup_missing.dart';
import 'widgets/relay_setup_searching.dart';
import 'widgets/relay_setup_unreachable.dart';

/// Post-login step for an account whose NIP-65 relay list is nowhere to be
/// found. Without it we don't know which relays to read, so the login stays
/// parked here until the list turns up or the user logs out.
class RelaySetupView extends StatelessWidget {
  const RelaySetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
            final pubkey = auth.publicKey;
            if (pubkey == null) return const SizedBox.shrink();
            // One controller per account: logging out here can land on another
            // account that has no list either, without leaving this route.
            return GetBuilder<RelaySetupController>(
              key: ValueKey(pubkey),
              tag: pubkey,
              init: RelaySetupController(),
              builder: (controller) => Center(
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
            );
          }),
        ),
      ),
    );
  }
}
