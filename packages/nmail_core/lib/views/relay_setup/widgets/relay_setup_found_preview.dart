import 'package:flutter/material.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/controllers/relay_setup_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/relay_list_discovery_result.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// The list the hint turned up, shown before anything is adopted so the user
/// can confirm it is theirs.
class RelaySetupFoundPreview extends StatelessWidget {
  const RelaySetupFoundPreview({
    super.key,
    required this.controller,
    required this.found,
  });

  final RelaySetupController controller;
  final RelayListFound found;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final relays = found.relays.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.relaySetupFoundTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.relaySetupFoundCount(relays.length),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < relays.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: segmentedListGap),
            child: ListTile(
              tileColor: theme.colorScheme.surfaceContainerHigh,
              shape: segmentedListShape(index: i, count: relays.length),
              minTileHeight: 56,
              leading: const Icon(Icons.dns_outlined),
              title: Text(
                formatRelayUrl(relays[i].key),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(switch (relays[i].value) {
                ReadWriteMarker.readOnly => Icons.south,
                ReadWriteMarker.writeOnly => Icons.north,
                ReadWriteMarker.readWrite => Icons.swap_vert,
              }, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: controller.isLeaving ? null : controller.useFoundList,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: controller.runningAction == RelaySetupAction.useFound
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.relaySetupUseFoundList),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: controller.isLeaving ? null : controller.discardFoundList,
          child: Text(l.relaySetupSearchAgain),
        ),
      ],
    );
  }
}
