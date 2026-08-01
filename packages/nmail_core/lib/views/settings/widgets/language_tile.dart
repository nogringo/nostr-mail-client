import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/language_names.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'language_dialog.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Obx(() {
        final current = controller.locale.value;
        return ListTile(
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: index, count: count),
          minTileHeight: 72,
          leading: const Icon(Icons.translate),
          title: Text(l.settingsLanguage),
          subtitle: Text(
            current == null ? l.settingsLanguageSystem : languageName(current),
          ),
          trailing: const Icon(Icons.expand_more),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const LanguageDialog(),
          ),
        );
      }),
    );
  }
}
