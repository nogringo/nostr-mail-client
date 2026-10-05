import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'copy_sync_code_tile.dart';
import 'settings_group.dart';
import 'settings_nav_tile.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = GetIt.I<AuthController>();
    final settings = GetIt.I<SettingsController>();
    final nsec = auth.getNsec();

    return ValueListenableBuilder(
      valueListenable: settings.debugToolsUnlocked,
      builder: (context, debugToolsUnlocked, _) => SettingsGroup(
        rows: [
          (index, count) => ValueListenableBuilder(
            valueListenable: auth.accountPubkeys,
            builder: (context, accountPubkeys, _) {
              final total = accountPubkeys.length;
              return SettingsNavTile(
                icon: Icons.manage_accounts_outlined,
                title: l.accountsTitle,
                badge: total < 2 ? null : '$total',
                index: index,
                count: count,
                onTap: () => context.go(AppRoutes.accounts),
              );
            },
          ),
          if (nsec != null)
            (index, count) =>
                CopySyncCodeTile(nsec: nsec, index: index, count: count),
          if (kDebugMode || debugToolsUnlocked)
            (index, count) => SettingsNavTile(
              icon: Icons.bug_report_outlined,
              title: l.settingsDebugTools,
              index: index,
              count: count,
              onTap: () => context.go(AppRoutes.settingsDebugTools),
            ),
        ],
      ),
    );
  }
}
