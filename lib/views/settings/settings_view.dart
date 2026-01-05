import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/toast_helper.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ResponsiveCenter(
        maxWidth: 600,
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader(context, 'Options avancées'),
            Obx(
              () => SwitchListTile(
                title: const Text('Afficher le code source des emails'),
                subtitle: const Text(
                  'Ajoute un bouton pour voir le contenu brut RFC 2822',
                ),
                value: settingsController.showRawEmail.value,
                onChanged: settingsController.setShowRawEmail,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Compte'),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Copier ma clé privée (nsec)'),
              subtitle: const Text('Gardez cette clé en sécurité'),
              onTap: () async {
                final authController = Get.find<AuthController>();
                final nsec = await authController.getNsec();
                if (nsec != null) {
                  await Clipboard.setData(ClipboardData(text: nsec));
                  if (context.mounted) {
                    ToastHelper.success(context, 'Clé privée copiée');
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.find<AuthController>().logout();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
