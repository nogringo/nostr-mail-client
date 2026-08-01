import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/language_names.dart';
import 'language_option_tile.dart';
import 'settings_group.dart';

/// The language choices themselves, shared by the dialog and the bottom sheet.
class LanguageOptionsList extends StatelessWidget {
  const LanguageOptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          rows: [
            (index, count) => LanguageOptionTile(
              locale: null,
              label: l.settingsLanguageSystem,
              index: index,
              count: count,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsGroup(
          rows: [
            for (final locale in pickableLocales)
              (index, count) => LanguageOptionTile(
                locale: locale,
                label: languageName(locale),
                index: index,
                count: count,
              ),
          ],
        ),
      ],
    );
  }
}
