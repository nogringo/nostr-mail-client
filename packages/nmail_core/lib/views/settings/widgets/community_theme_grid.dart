import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'community_theme_card.dart';

class CommunityThemeGrid extends StatelessWidget {
  const CommunityThemeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = Get.find<CommunityThemesController>();
    final isWide = ResponsiveHelper.isNotMobile(context);

    return Obx(() {
      final themes = controller.visibleThemes(filterByImage: isWide);
      if (themes.isEmpty) {
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          sliver: SliverToBoxAdapter(
            child: Text(
              l.communityThemesNoMatch,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            mainAxisExtent: 184,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
          ),
          itemCount: themes.length,
          itemBuilder: (_, index) => CommunityThemeCard(
            key: ValueKey(themes[index].address),
            theme: themes[index],
          ),
        ),
      );
    });
  }
}
