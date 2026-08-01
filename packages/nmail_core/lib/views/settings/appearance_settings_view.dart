import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'widgets/background_section.dart';
import 'widgets/language_tile.dart';
import 'widgets/theme_mode_section.dart';

class AppearanceSettingsView extends StatelessWidget {
  const AppearanceSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAppearance)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveCenter(
            maxWidth: 600,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8),
                ThemeModeSection(),
                SizedBox(height: 12),
                BackgroundSection(),
                SizedBox(height: 12),
                LanguageTile(index: 0, count: 1),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
