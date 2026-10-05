import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class CommunityThemeFilter extends StatelessWidget {
  const CommunityThemeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<CommunityThemesController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SegmentedButton<Brightness?>(
        segments: [
          ButtonSegment(value: null, label: Text(l.communityThemesFilterAll)),
          ButtonSegment(
            value: Brightness.light,
            icon: const Icon(Icons.light_mode),
            label: Text(l.settingsThemeLight),
          ),
          ButtonSegment(
            value: Brightness.dark,
            icon: const Icon(Icons.dark_mode),
            label: Text(l.settingsThemeDark),
          ),
        ],
        selected: {controller.brightness},
        showSelectedIcon: false,
        onSelectionChanged: (selection) =>
            controller.brightness = selection.single,
      ),
    );
  }
}
