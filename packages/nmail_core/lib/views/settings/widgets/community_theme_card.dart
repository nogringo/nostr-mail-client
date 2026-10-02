import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'community_theme_preview.dart';

class CommunityThemeCard extends StatelessWidget {
  const CommunityThemeCard({super.key, required this.theme});

  final CommunityTheme theme;

  static final _radius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunityThemesController>();
    final settings = Get.find<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final isSelected = settings.communityTheme.value == theme.address;
      final isApplying = controller.applying.value == theme.address;
      final author = Get.find<MetadataService>().of(theme.pubkey).value;

      return Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          borderRadius: _radius,
          onTap: () => controller.apply(context, theme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: _radius,
                      child: CommunityThemePreview(theme: theme),
                    ),
                    if (isSelected)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: _radius,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                    if (isApplying)
                      ClipRRect(
                        borderRadius: _radius,
                        child: ColoredBox(
                          color: colorScheme.scrim.withValues(alpha: 0.32),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                theme.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: isSelected ? colorScheme.primary : null,
                ),
              ),
              Text(
                author?.getBestName() ?? getAnonName(theme.pubkey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
