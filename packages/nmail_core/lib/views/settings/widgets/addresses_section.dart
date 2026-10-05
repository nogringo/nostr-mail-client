import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/identities_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_group.dart';
import 'settings_nav_tile.dart';

class AddressesSection extends StatelessWidget {
  const AddressesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final identities = GetIt.I<IdentitiesController>();

    return SettingsGroup(
      rows: [
        (index, count) => ListenableBuilder(
          listenable: identities,
          builder: (context, _) {
            final total = identities.identities.length;
            return SettingsNavTile(
              icon: Icons.alternate_email,
              title: l.settingsIdentities,
              badge: total == 0 ? null : '$total',
              index: index,
              count: count,
              onTap: () => context.go(AppRoutes.settingsIdentities),
            );
          },
        ),
        (index, count) => SettingsNavTile(
          icon: Icons.cloud_outlined,
          title: l.settingsHosting,
          index: index,
          count: count,
          onTap: () => context.go(AppRoutes.settingsHosting),
        ),
      ],
    );
  }
}
