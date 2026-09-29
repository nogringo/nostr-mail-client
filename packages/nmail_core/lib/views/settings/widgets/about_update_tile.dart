import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/app_update_service.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

class AboutUpdateTile extends StatelessWidget {
  const AboutUpdateTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final updates = Get.find<AppUpdateService>();

    return Obx(() {
      final release = updates.availableUpdate.value;
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
    });
  }
}
