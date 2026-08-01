import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// One language choice. The picked row detaches from the group with its own
/// full rounding, so the selection reads without relying on colour alone.
class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    super.key,
    required this.locale,
    required this.label,
    required this.index,
    required this.count,
  });

  final Locale? locale;
  final String label;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Obx(() {
        final isSelected = controller.locale.value == locale;
        final isAlone = count == 1;
        return ListTile(
          selected: isSelected,
          tileColor: colorScheme.surfaceContainerHigh,
          selectedTileColor: colorScheme.secondaryContainer,
          selectedColor: colorScheme.onSecondaryContainer,
          shape: isAlone
              ? const StadiumBorder()
              : segmentedListShape(
                  index: index,
                  count: count,
                  isSelected: isSelected,
                ),
          contentPadding: isAlone
              ? const EdgeInsets.symmetric(horizontal: 24)
              : null,
          minTileHeight: 56,
          title: Text(label),
          trailing: isSelected ? const Icon(Icons.check) : null,
          onTap: () {
            if (!isSelected) controller.setLocale(locale);
            Navigator.pop(context);
          },
        );
      }),
    );
  }
}
