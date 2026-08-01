import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/app_routes.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/about_section.dart';
import 'widgets/account_section.dart';
import 'widgets/addresses_section.dart';
import 'widgets/app_preferences_section.dart';
import 'widgets/danger_zone_section.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          // Reached via `context.go` from inbox/drawer/rail, so there is
          // typically nothing to pop. Fall back to the inbox.
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.inbox),
        ),
        title: Text(l.settingsTitle),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 600,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                AddressesSection(),
                SizedBox(height: 12),
                AppPreferencesSection(),
                SizedBox(height: 12),
                AccountSection(),
                SizedBox(height: 12),
                AboutSection(),
                SizedBox(height: 12),
                DangerZoneSection(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
