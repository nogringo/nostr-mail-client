import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_group.dart';
import 'settings_nav_tile.dart';

class CommunityThemesSection extends StatelessWidget {
  const CommunityThemesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SettingsGroup(
      rows: [
        (index, count) => SettingsNavTile(
          icon: Icons.style_outlined,
          title: l.settingsCommunityThemes,
          index: index,
          count: count,
          onTap: () => context.go(AppRoutes.settingsAppearanceThemes),
        ),
      ],
    );
  }
}
