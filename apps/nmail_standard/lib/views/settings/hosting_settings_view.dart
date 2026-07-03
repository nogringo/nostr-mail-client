import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import 'widgets/bridges_section.dart';
import 'widgets/blossom_servers_section.dart';
import 'widgets/dm_relays_section.dart';
import 'widgets/nip65_relays_section.dart';
import 'widgets/relay_connectivity_section.dart';
import 'widgets/sync_status_section.dart';

class HostingSettingsView extends StatelessWidget {
  const HostingSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    Widget content = Scaffold(
      appBar: AppBar(title: Text(l.settingsHosting)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 600,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Nip65RelaysSection(),
                  const SizedBox(height: 16),
                  const DmRelaysSection(),
                  const SizedBox(height: 16),
                  const BlossomServersSection(),
                  const SizedBox(height: 16),
                  const BridgesSection(),
                  const SizedBox(height: 16),
                  const RelayConnectivitySection(),
                  const SizedBox(height: 8),
                  const SyncStatusSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return content;
  }
}
