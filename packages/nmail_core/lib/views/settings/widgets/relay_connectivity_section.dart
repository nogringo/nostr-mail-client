import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/relay_connectivity_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'relay_connectivity_tile.dart';
import 'settings_section_header.dart';

class RelayConnectivitySection extends StatelessWidget {
  const RelayConnectivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<RelayConnectivityController>(
      init: RelayConnectivityController(),
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionHeader(title: l.connectivitySectionTitle),
          RelayConnectivityTile(
            connectivity: controller.connectivityMap,
            connectedCount: controller.connectedCount,
          ),
        ],
      ),
    );
  }
}
