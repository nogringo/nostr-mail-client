import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class RegistrationForm extends GetView<AuthController> {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.authRegisterPrompt,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.usernameController,
            enabled: !controller.isLoading.value,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              if (controller.isLoading.value) return;
              controller.register();
            },
            decoration: InputDecoration(
              labelText: l.authDisplayNameLabel,
              hintText: l.authDisplayNameHint,
              prefixIcon: const Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed:
                controller.username.value.isEmpty || controller.isLoading.value
                ? null
                : controller.register,
            child: Text(l.actionContinue),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    controller.isRegistering.value = false;
                    controller.usernameController.clear();
                  },
            child: Text(l.authBackToLogin),
          ),
        ],
      ),
    );
  }
}
