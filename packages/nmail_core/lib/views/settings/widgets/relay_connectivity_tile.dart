import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'relay_connectivity_row.dart';

/// Live connection count, expanding into the relays behind it.
class RelayConnectivityTile extends StatelessWidget {
  const RelayConnectivityTile({
    super.key,
    required this.relays,
    required this.connectedCount,
    required this.isDeviceOffline,
  });

  final Map<String, bool> relays;
  final int connectedCount;
  final bool isDeviceOffline;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: 0, count: 1),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          // Dividers would cut across the group's single rounded surface.
          shape: const Border(),
          collapsedShape: const Border(),
          childrenPadding: const EdgeInsets.fromLTRB(56, 0, 0, 8),
          leading: Icon(connectedCount > 0 ? Icons.wifi : Icons.wifi_off),
          title: Text(
            l.connectivityConnectedCount(connectedCount, relays.length),
          ),
          subtitle: isDeviceOffline ? Text(l.connectivityDeviceOffline) : null,
          children: [
            for (final entry in relays.entries)
              RelayConnectivityRow(url: entry.key, isConnected: entry.value),
          ],
        ),
      ),
    );
  }
}
