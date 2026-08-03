import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Progress of the automatic sweep. Stays blank for the first moments so a
/// search that resolves at once doesn't flash a spinner.
class RelaySetupSearching extends StatelessWidget {
  const RelaySetupSearching({super.key, required this.controller});

  final RelaySetupController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.showProgress) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          l.relaySetupSearching,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
