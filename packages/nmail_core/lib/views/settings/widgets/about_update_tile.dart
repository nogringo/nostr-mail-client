import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/app_update_service.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

class AboutUpdateTile extends StatelessWidget {
  const AboutUpdateTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final updates = GetIt.I<AppUpdateService>();

    return ValueListenableBuilder(
      valueListenable: updates.availableUpdate,
      builder: (context, release, _) {
        if (release == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, segmentedListGap / 2),
          child: ListTile(
            tileColor: colorScheme.primaryContainer,
            textColor: colorScheme.onPrimaryContainer,
            iconColor: colorScheme.onPrimaryContainer,
            shape: segmentedListShape(index: 0, count: 1),
            minTileHeight: 72,
            leading: const Icon(Icons.new_releases_outlined),
            title: Text(l.settingsUpdateAvailable(release.version)),
            trailing: FilledButton(
              onPressed: updates.openUpdate,
              child: Text(
                kIsWeb ? l.settingsUpdateReload : l.settingsUpdateInstall,
              ),
            ),
          ),
        );
      },
    );
  }
}
