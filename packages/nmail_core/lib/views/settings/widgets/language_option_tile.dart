import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    final controller = GetIt.I<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ValueListenableBuilder(
        valueListenable: controller.locale,
        builder: (context, current, _) {
          final isSelected = current == locale;
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
            onTap: () {
              if (!isSelected) controller.setLocale(locale);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
