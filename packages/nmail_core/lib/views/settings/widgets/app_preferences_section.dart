import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_group.dart';
import 'settings_nav_tile.dart';

class AppPreferencesSection extends StatelessWidget {
  const AppPreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SettingsGroup(
      rows: [
        (index, count) => SettingsNavTile(
          icon: Icons.mail_outline,
          title: l.settingsMessages,
          index: index,
          count: count,
          onTap: () => context.go(AppRoutes.settingsMessages),
        ),
        (index, count) => SettingsNavTile(
          icon: Icons.notifications_outlined,
          title: l.settingsNotifications,
          index: index,
          count: count,
          onTap: () => context.go(AppRoutes.settingsNotifications),
        ),
        (index, count) => SettingsNavTile(
          icon: Icons.palette_outlined,
          title: l.settingsAppearance,
          index: index,
          count: count,
          onTap: () => context.go(AppRoutes.settingsAppearance),
        ),
      ],
    );
  }
}
