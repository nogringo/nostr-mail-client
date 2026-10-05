import 'package:flutter/material.dart';

import '../../../controllers/relay_connectivity_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/widgets/controller_builder.dart';
import 'relay_connectivity_tile.dart';
import 'settings_section_header.dart';

class RelayConnectivitySection extends StatelessWidget {
  const RelayConnectivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ControllerBuilder(
      create: RelayConnectivityController.new,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionHeader(title: l.connectivitySectionTitle),
          RelayConnectivityTile(
            relays: controller.relays,
            connectedCount: controller.connectedCount,
            isDeviceOffline: controller.isDeviceOffline,
          ),
        ],
      ),
    );
  }
}
