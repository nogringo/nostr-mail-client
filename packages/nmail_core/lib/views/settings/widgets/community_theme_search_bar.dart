import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class CommunityThemeSearchBar extends StatelessWidget {
  const CommunityThemeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<CommunityThemesController>();

    return SearchBar(
      controller: controller.searchController,
      hintText: l.communityThemesSearchHint,
      // It scrolls with the grid, so it should not look like it floats.
      elevation: const WidgetStatePropertyAll(0),
      leading: const Icon(Icons.search),
      textInputAction: TextInputAction.search,
      trailing: [
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) => controller.query.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                  onPressed: controller.searchController.clear,
                ),
        ),
      ],
    );
  }
}
