import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/app_update_service.dart';
import 'settings_group.dart';
import 'settings_nav_tile.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final updates = GetIt.I<AppUpdateService>();

    return SettingsGroup(
      rows: [
        (index, count) => ValueListenableBuilder(
          valueListenable: updates.availableUpdate,
          builder: (context, release, _) => SettingsNavTile(
            icon: Icons.info_outline,
            title: l.settingsAbout,
            index: index,
            count: count,
            showDot: release != null,
            onTap: () => context.go(AppRoutes.settingsAbout),
          ),
        ),
      ],
    );
  }
}
