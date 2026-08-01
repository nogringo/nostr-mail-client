import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/sensitive_clipboard.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'widgets/settings_section_header.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsController = Get.find<SettingsController>();

    Widget content = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          // Reached via `context.go` from inbox/drawer/rail, so there is
          // typically nothing to pop. Fall back to the inbox.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.inbox),
        ),
        title: Text(l.settingsTitle),
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              SettingsSectionHeader(title: l.settingsAppearance),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(l.settingsManageAppearance),
                subtitle: Text(l.settingsManageAppearanceSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsAppearance),
              ),
              const SizedBox(height: 16),
              SettingsSectionHeader(title: l.settingsNotifications),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l.settingsManageNotifications),
                subtitle: Text(l.settingsManageNotificationsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsNotifications),
              ),
              const SizedBox(height: 16),
              SettingsSectionHeader(title: l.settingsAdvancedOptions),
              Obx(
                () => SwitchListTile(
                  title: Text(l.settingsAlwaysLoadImages),
                  subtitle: Text(l.settingsAlwaysLoadImagesSubtitle),
                  value: settingsController.alwaysLoadImages.value,
                  onChanged: settingsController.setAlwaysLoadImages,
                ),
              ),
              const SizedBox(height: 24),
              SettingsSectionHeader(title: l.settingsIdentities),
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: Text(l.settingsManageIdentities),
                subtitle: Text(l.settingsManageIdentitiesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsIdentities),
              ),
              const SizedBox(height: 24),
              SettingsSectionHeader(title: l.settingsCompose),
              Obx(() {
                final signature = settingsController.emailSignature.value;
                return ListTile(
                  leading: const Icon(Icons.edit_note),
                  title: Text(l.settingsEmailSignature),
                  subtitle: signature.isEmpty
                      ? Text(l.settingsEmailSignatureEmpty)
                      : Text(signature),
                  onTap: () =>
                      _showSignatureDialog(context, settingsController),
                );
              }),
              const SizedBox(height: 24),
              SettingsSectionHeader(title: l.settingsSynchronization),
              ListTile(
                leading: const Icon(Icons.cloud_outlined),
                title: Text(l.settingsHosting),
                subtitle: Text(l.settingsHostingSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsHosting),
              ),
              if (kDebugMode)
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(l.settingsDebugTools),
                  subtitle: Text(l.settingsDebugToolsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(AppRoutes.settingsDebugTools),
                ),
              const SizedBox(height: 24),
              SettingsSectionHeader(title: l.settingsAccount),
              ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: Text(l.accountsManage),
                subtitle: Text(l.accountsManageSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.accounts),
              ),
              Builder(
                builder: (context) {
                  final authController = Get.find<AuthController>();
                  final nsec = authController.getNsec();
                  if (nsec == null) return const SizedBox.shrink();
                  return ListTile(
                    leading: const Icon(Icons.key),
                    title: Text(l.settingsCopySyncCode),
                    subtitle: Text(l.settingsCopySyncCodeSubtitle),
                    onTap: () async {
                      await SensitiveClipboard.copy(nsec, label: 'sync code');
                      if (!PlatformHelper.isAndroid && context.mounted) {
                        ToastHelper.success(context, l.settingsSyncCodeCopied);
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l.settingsLogOut,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Get.find<AuthController>().logout();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l.settingsResetApplication,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: Text(l.settingsResetApplicationSubtitle),
                onTap: () => _showResetConfirmationDialog(context),
              ),
              const SizedBox(height: 24),
              SettingsSectionHeader(title: l.settingsAbout),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.settingsAboutApp),
                subtitle: Text(l.settingsAboutAppSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(AppRoutes.settingsAbout),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );

    return content;
  }

  void _showResetConfirmationDialog(BuildContext context) {
    final l = AppLocalizations.of(context);
    Get.dialog(
      AlertDialog(
        title: Text(l.settingsResetApplication),
        content: Text(l.settingsResetConfirmMessage),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () async {
              Get.back();
              Get.dialog(
                AlertDialog(
                  content: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Text(l.stateResetting),
                    ],
                  ),
                ),
                barrierDismissible: false,
              );
              await Get.find<SettingsController>().resetApplication();
            },
            child: Text(
              l.actionReset,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignatureDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    final textController = TextEditingController(
      text: controller.emailSignature.value,
    );

    Get.dialog(
      AlertDialog(
        title: Text(l.settingsEmailSignature),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: l.settingsEmailSignatureHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
          TextButton(
            onPressed: () {
              controller.setEmailSignature(textController.text);
              Get.back();
            },
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
  }
}
