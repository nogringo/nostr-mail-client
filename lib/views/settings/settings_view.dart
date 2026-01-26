import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/toast_helper.dart';
import 'widgets/dm_relays_section.dart';
import 'widgets/sync_status_section.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Advanced options'),
              Obx(
                () => SwitchListTile(
                  title: const Text('Show email source code'),
                  subtitle: const Text(
                    'Adds a button to view raw RFC 2822 content',
                  ),
                  value: settingsController.showRawEmail.value,
                  onChanged: settingsController.setShowRawEmail,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  title: const Text('Always load images'),
                  subtitle: const Text(
                    'Images are blocked by default for privacy',
                  ),
                  value: settingsController.alwaysLoadImages.value,
                  onChanged: settingsController.setAlwaysLoadImages,
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Account'),
              Builder(
                builder: (context) {
                  final authController = Get.find<AuthController>();
                  final nsec = authController.getNsec();
                  if (nsec == null) return const SizedBox.shrink();
                  return ListTile(
                    leading: const Icon(Icons.key),
                    title: const Text('Copy my private key (nsec)'),
                    subtitle: const Text('Keep this key safe'),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: nsec));
                      if (context.mounted) {
                        ToastHelper.success(context, 'Private key copied');
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.find<AuthController>().logout();
                  Get.offAllNamed('/login');
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Synchronization'),
              const DmRelaysSection(),
              const SizedBox(height: 16),
              const SyncStatusSection(),
            ],
          ),
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
