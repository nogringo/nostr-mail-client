import 'package:flutter/material.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'relay_hint_form.dart';
import 'relay_setup_found_preview.dart';

/// The relays answered and this account has no NIP-65 list on them. Two ways
/// out: point us somewhere else, or publish a new list.
class RelaySetupMissing extends StatelessWidget {
  const RelaySetupMissing({super.key, required this.controller});

  final RelaySetupController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final found = controller.hintResult;
    if (found != null) {
      return RelaySetupFoundPreview(controller: controller, found: found);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.relaySetupMissingTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(
          l.relaySetupMissingDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        RelayHintForm(controller: controller),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l.relaySetupOr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: controller.isLeaving ? null : controller.createRelayList,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: controller.runningAction == RelaySetupAction.create
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.relaySetupCreate),
        ),
        const SizedBox(height: 8),
        Text(
          l.relaySetupCreateDescription(
            NostrConfig.recommendedInboxOutboxRelays
                .map(formatRelayUrl)
                .join(', '),
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
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
              : Text(l.relaySetupContinueWithout),
        ),
      ],
    );
  }
}
