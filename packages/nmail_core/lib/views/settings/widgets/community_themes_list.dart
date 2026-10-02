import 'dart:math';

import 'package:flutter/material.dart';

import 'package:nmail_core/utils/responsive_helper.dart';
import 'community_theme_color_filter.dart';
import 'community_theme_filter.dart';
import 'community_theme_grid.dart';
import 'community_theme_image_filter.dart';

class CommunityThemesList extends StatelessWidget {
  const CommunityThemesList({super.key});

  static const _maxWidth = 960.0;

  @override
  Widget build(BuildContext context) {
    // The background only shows on wide layouts.
    final isWide = ResponsiveHelper.isNotMobile(context);

    // Centered by padding, not a width constraint, to keep the scrollbar at the
    // screen edge.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = max(0.0, (constraints.maxWidth - _maxWidth) / 2);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const CommunityThemeFilter(),
                          if (isWide) const CommunityThemeImageFilter(),
                          const CommunityThemeColorFilter(),
                        ],
                      ),
                    ),
                  ),
                  const CommunityThemeGrid(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
