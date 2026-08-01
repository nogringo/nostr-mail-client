import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/blossom_servers_section.dart';
import 'widgets/bridges_section.dart';
import 'widgets/dm_relays_section.dart';
import 'widgets/hosting_save_button.dart';
import 'widgets/nip65_relays_section.dart';
import 'widgets/relay_connectivity_section.dart';
import 'widgets/sync_status_section.dart';

class HostingSettingsView extends StatelessWidget {
  const HostingSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsHosting),
        actionsPadding: .only(right: 8),
        actions: const [HostingSaveButton()],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: const ResponsiveCenter(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Nip65RelaysSection(),
                DmRelaysSection(),
                BlossomServersSection(),
                BridgesSection(),
                RelayConnectivitySection(),
                SyncStatusSection(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
