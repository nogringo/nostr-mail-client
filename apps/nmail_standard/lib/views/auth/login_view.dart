import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/responsive_helper.dart';
import 'widgets/auth_header.dart';
import 'widgets/login_form.dart';
import 'widgets/registration_form.dart';
import 'widgets/sync_code_explanation_view.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const AuthHeader(),
                    const SizedBox(height: 48),
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
  }
}
