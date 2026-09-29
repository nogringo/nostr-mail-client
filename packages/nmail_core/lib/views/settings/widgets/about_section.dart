import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final updates = Get.find<AppUpdateService>();

    return SettingsGroup(
      rows: [
        (index, count) => Obx(
          () => SettingsNavTile(
            icon: Icons.info_outline,
            title: l.settingsAbout,
            index: index,
            count: count,
            showDot: updates.availableUpdate.value != null,
            onTap: () => context.go(AppRoutes.settingsAbout),
          ),
        ),
      ],
    );
  }
}
