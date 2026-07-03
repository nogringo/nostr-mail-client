import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../services/sensitive_clipboard.dart';
import '../../../utils/toast_helper.dart';

class SyncCodeExplanationView extends StatelessWidget {
  final RxBool _hasCopied = false.obs;

  SyncCodeExplanationView({super.key});

  void _copySyncCode(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authController = Get.find<AuthController>();
    final nsec = authController.getNsec();

    if (nsec == null) {
      if (context.mounted) {
        ToastHelper.error(context, l.authUnableRetrieveCode);
      }
      return;
    }

    SensitiveClipboard.copy(nsec, label: 'sync code');
    _hasCopied.value = true;

    Future.delayed(const Duration(seconds: 2), () {
      _hasCopied.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        Text(
          l.authYourSyncCode,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        Text(
          l.authSyncCodeIntro,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        _buildFeatureItem(
          context,
          Icons.restore_page,
          l.authSyncCodeFeatureRestore,
        ),
        _buildFeatureItem(
          context,
          Icons.backup_rounded,
          l.authSyncCodeFeatureBackup,
        ),
        _buildFeatureItem(
          context,
          Icons.login_rounded,
          l.authSyncCodeFeatureLogin,
        ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.errorContainer, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l.authSyncCodeWarning, style: textTheme.bodyMedium),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Obx(
          () => FilledButton.icon(
            onPressed: () => _copySyncCode(context),
            icon: Icon(_hasCopied.value ? Icons.check : Icons.copy_all_rounded),
            label: Text(
              _hasCopied.value ? l.authCopied : l.authCopySyncCode,
              style: const TextStyle(fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton(
          onPressed: () {
            final authController = Get.find<AuthController>();
            authController.continueToInbox();
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            l.authContinueToInbox,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
