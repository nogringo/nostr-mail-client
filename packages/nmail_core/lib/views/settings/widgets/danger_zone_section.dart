import 'package:flutter/material.dart';

import 'package:nmail_core/views/shared/confirm_logout.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'delete_account_tile.dart';
import 'reset_application_tile.dart';
import 'settings_action_tile.dart';
import 'settings_group.dart';

class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SettingsGroup(
      rows: [
        (index, count) => SettingsActionTile(
          icon: Icons.logout,
          title: l.settingsLogOut,
          isDestructive: true,
          index: index,
          count: count,
          onTap: () => confirmLogout(context),
        ),
        (index, count) => DeleteAccountTile(index: index, count: count),
        (index, count) => ResetApplicationTile(index: index, count: count),
      ],
    );
  }
}
