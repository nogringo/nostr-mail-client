import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_router.dart';
import '../../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/auth_header.dart';
import 'widgets/login_form.dart';
import 'widgets/registration_form.dart';
import 'widgets/sync_code_explanation_view.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key, this.isAddingAccount = false});

  /// Reached from `/accounts/add` while already logged in, where the user
  /// needs a way back to the inbox.
  final bool isAddingAccount;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: isAddingAccount
          ? AppBar(
              title: Text(AppLocalizations.of(context).inboxAddAccount),
              leading: Obx(
                // No shortcut past the sync code backup of a fresh account.
                () => controller.showSyncCodeExplanation.value
                    ? const SizedBox.shrink()
                    : BackButton(onPressed: AppRouter.popOrGoInbox),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 400,
              padding: const EdgeInsets.all(24),
              child: Obx(() {
                // Show sync code explanation after registration
                if (controller.showSyncCodeExplanation.value) {
                  return SyncCodeExplanationView();
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isAddingAccount) ...[
                      const AuthHeader(),
                      const SizedBox(height: 48),
                    ],
                    Stack(
                      children: [
                        // Login Form
                        AnimatedOpacity(
                          opacity: controller.isRegistering.value ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Visibility(
                            visible: !controller.isRegistering.value,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: const LoginForm(),
                          ),
                        ),
                        // Registration Form
                        AnimatedOpacity(
                          opacity: controller.isRegistering.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Visibility(
                            visible: controller.isRegistering.value,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: const RegistrationForm(),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );

    if (!isAddingAccount) return scaffold;

    // Entered with `go`, so there is nothing to pop: without this the OS
    // back button would leave the app instead of returning to the inbox.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        AppRouter.popOrGoInbox();
      },
      child: scaffold,
    );
  }
}
