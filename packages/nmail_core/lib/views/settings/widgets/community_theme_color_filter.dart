import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/theme_color_family.dart';
import '../../mailboxes/widgets/entry_color_swatch.dart';

class CommunityThemeColorFilter extends StatelessWidget {
  const CommunityThemeColorFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<CommunityThemesController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final selected = controller.colorFamily;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            EntryColorSwatch(
              color: null,
              label: l.communityThemesAllColors,
              selected: selected == null,
              onTap: () => controller.colorFamily = null,
            ),
            for (final family in ThemeColorFamily.values)
              EntryColorSwatch(
                color: family.swatch,
                label: l.colorName(family.name),
                selected: selected == family,
                onTap: () => controller.colorFamily = family,
              ),
          ],
        );
      },
    );
  }
}
