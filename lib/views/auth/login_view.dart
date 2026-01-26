import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_widgets/nostr_widgets.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/responsive_helper.dart';

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'icons/original_transparent_3x.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nostr Mail',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email over Nostr',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  NLogin(
                    ndk: controller.ndk,
                    onLoggedIn: () {
                      controller.onLoggedIn();
                      Get.offAllNamed('/inbox');
                    },
                    enableNpubLogin: false,
                    enableNip05Login: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
