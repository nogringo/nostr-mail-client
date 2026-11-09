import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/screen_security.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/always_load_images_tile.dart';
import 'widgets/doh_server_tile.dart';
import 'widgets/screen_security_tile.dart';
import 'widgets/settings_group.dart';
import 'widgets/signatures_nav_tile.dart';

class MessagesSettingsView extends StatelessWidget {
  const MessagesSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsMessages)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                SettingsGroup(
                  rows: [
                    (index, count) =>
                        SignaturesNavTile(index: index, count: count),
                    (index, count) =>
                        AlwaysLoadImagesTile(index: index, count: count),
                    if (ScreenSecurity.isSupported)
                      (index, count) =>
                          ScreenSecurityTile(index: index, count: count),
                    (index, count) => DohServerTile(index: index, count: count),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
