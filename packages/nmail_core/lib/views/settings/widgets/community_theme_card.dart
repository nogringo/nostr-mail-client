import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'community_theme_preview.dart';
import 'community_theme_warning.dart';

class CommunityThemeCard extends StatelessWidget {
  const CommunityThemeCard({super.key, required this.theme});

  final CommunityTheme theme;

  static final _radius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<CommunityThemesController>();
    final settings = GetIt.I<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final author = GetIt.I<MetadataService>().of(theme.pubkey);

    return ListenableBuilder(
      listenable: Listenable.merge([
        controller,
        author,
        settings.communityTheme,
      ]),
      builder: (context, _) {
        final isSelected = settings.communityTheme.value == theme.address;
        final isHidden = controller.isHidden(theme);
        final imageUrl = theme.backgroundImageUrl;

        return Semantics(
          button: true,
          selected: isSelected,
          child: InkWell(
            borderRadius: _radius,
            onTap: () => context.go(AppRoutes.communityThemePath(theme)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: _radius,
                        child: CommunityThemePreview(
                          colorScheme: theme.colorScheme,
                          background: imageUrl == null || isHidden
                              ? null
                              : Image(
                                  image: ResizeImage(
                                    NetworkImage(imageUrl),
                                    width: 480,
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
                                ),
                        ),
                      ),
                      if (isHidden)
                        CommunityThemeWarning(
                          reason: theme.contentWarning!,
                          onShow: () => controller.reveal(theme),
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
                  author.value?.getBestName() ?? getAnonName(theme.pubkey),
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
      },
    );
  }
}
