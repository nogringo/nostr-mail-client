import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'widgets/community_theme_color_filter.dart';
import 'widgets/community_theme_filter.dart';
import 'widgets/community_theme_grid.dart';
import 'widgets/community_themes_empty_state.dart';

class CommunityThemesView extends StatelessWidget {
  const CommunityThemesView({super.key});

  static const _maxWidth = 960.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<CommunityThemesController>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsCommunityThemes)),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.themes.isEmpty) {
            return controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : const CommunityThemesEmptyState();
          }

          // Centered by padding, not a width constraint, to keep the scrollbar
          // at the screen edge.
          return LayoutBuilder(
            builder: (context, constraints) {
              final gutter = max(0.0, (constraints.maxWidth - _maxWidth) / 2);
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: gutter),
                    sliver: const SliverMainAxisGroup(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          sliver: SliverToBoxAdapter(
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                CommunityThemeFilter(),
                                CommunityThemeColorFilter(),
                              ],
                            ),
                          ),
                        ),
                        CommunityThemeGrid(),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
