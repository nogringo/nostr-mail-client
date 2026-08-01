import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// Reads every message from the relays again, closing the sync group.
class ResyncTile extends StatelessWidget {
  const ResyncTile({
    super.key,
    required this.isSyncing,
    required this.onResync,
    required this.index,
    required this.count,
  });

  final bool isSyncing;
  final VoidCallback onResync;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 72,
        leading: isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        title: Text(l.syncStatusResync),
        subtitle: Text(l.syncStatusResyncSubtitle),
        onTap: isSyncing ? null : onResync,
      ),
    );
  }
}
