import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

class ScreenSecurityTile extends StatelessWidget {
  const ScreenSecurityTile({
    super.key,
    required this.index,
    required this.count,
  });

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = GetIt.I<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ValueListenableBuilder(
        valueListenable: settings.screenSecurity,
        builder: (context, screenSecurity, _) => SwitchListTile(
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: index, count: count),
          minTileHeight: 72,
          secondary: const Icon(Icons.screen_lock_portrait_outlined),
          title: Text(l.settingsScreenSecurity),
          subtitle: Text(l.settingsScreenSecuritySubtitle),
          value: screenSecurity,
          onChanged: settings.setScreenSecurity,
        ),
      ),
    );
  }
}
