import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// No relay answered, so the missing list proves nothing. Offers a retry and
/// nothing else: creating a list here could overwrite one that already exists.
class RelaySetupUnreachable extends StatelessWidget {
  const RelaySetupUnreachable({super.key, required this.controller});

  final RelaySetupController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.cloud_off,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 24),
        Text(
          l.relaySetupUnreachableTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          l.relaySetupUnreachableDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: controller.isLeaving ? null : controller.retryAutoSearch,
          icon: const Icon(Icons.refresh),
          label: Text(l.relaySetupRetry),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: controller.isLeaving
              ? null
              : controller.continueWithoutList,
          child: controller.runningAction == RelaySetupAction.continueWithout
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.relaySetupContinueAnyway),
        ),
      ],
    );
  }
}
