import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/relay_connectivity_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/relay_utils.dart';

class RelayConnectivitySection extends StatelessWidget {
  const RelayConnectivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GetBuilder<RelayConnectivityController>(
      init: RelayConnectivityController(),
      builder: (controller) {
        final connected = controller.connectedCount;
        final total = controller.connectivityMap.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.connectivitySectionTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            ExpansionTile(
              onExpansionChanged: controller.setExpanded,
              leading: Icon(
                connected > 0 ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              title: Text(
                l.connectivityRelayConnectivity,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$connected / $total',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: controller.isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
              children: controller.connectivityMap.entries.map((entry) {
                final url = entry.key;
                final connectivity = entry.value;
                final isConnected = connectivity.isConnected;

                return ListTile(
                  dense: true,
                  leading: Icon(
                    isConnected ? Icons.power : Icons.power_off,
                    color: isConnected
                        ? colorScheme.primary
                        : colorScheme.outline,
                    size: 16,
                  ),
                  title: Text(
                    formatRelayUrl(url),
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
