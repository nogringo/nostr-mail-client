import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/theme_color_family.dart';
import '../../mailboxes/widgets/entry_color_swatch.dart';

class CommunityThemeColorFilter extends StatelessWidget {
  const CommunityThemeColorFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<CommunityThemesController>();

    return Obx(() {
      final selected = controller.colorFamily.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          EntryColorSwatch(
            color: null,
            label: l.communityThemesAllColors,
            selected: selected == null,
            onTap: () => controller.colorFamily.value = null,
          ),
          for (final family in ThemeColorFamily.values)
            EntryColorSwatch(
              color: family.swatch,
              label: l.colorName(family.name),
              selected: selected == family,
              onTap: () => controller.colorFamily.value = family,
            ),
        ],
      );
    });
  }
}
