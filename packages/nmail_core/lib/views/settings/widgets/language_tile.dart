import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/language_names.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'show_language_picker.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = GetIt.I<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ValueListenableBuilder(
        valueListenable: controller.locale,
        builder: (context, current, _) {
          return ListTile(
            tileColor: colorScheme.surfaceContainerHigh,
            shape: segmentedListShape(index: index, count: count),
            minTileHeight: 72,
            leading: const Icon(Icons.translate),
            title: Text(l.settingsLanguage),
            subtitle: Text(
              current == null
                  ? l.settingsLanguageSystem
                  : languageName(current),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLanguagePicker(context),
          );
        },
      ),
    );
  }
}
