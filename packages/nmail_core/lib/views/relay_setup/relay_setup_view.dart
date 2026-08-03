import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/relay_setup_missing.dart';
import 'widgets/relay_setup_searching.dart';
import 'widgets/relay_setup_unreachable.dart';

/// Post-login step for an account whose NIP-65 relay list is nowhere to be
/// found. Without it we don't know which relays to read, so the login stays
/// parked here until the list turns up or the user decides to move on.
class RelaySetupView extends StatelessWidget {
  const RelaySetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RelaySetupController>(
      init: RelaySetupController(),
      builder: (controller) => PopScope(
        canPop: false,
        child: Scaffold(
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
      ),
    );
  }
}
