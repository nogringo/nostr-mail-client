import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/community_theme_controller.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'community_theme_preview.dart';
import 'community_theme_warning.dart';

/// The card preview scaled up, so it keeps the card's proportions.
class CommunityThemeLargePreview extends StatelessWidget {
  const CommunityThemeLargePreview({super.key, required this.theme});

  final CommunityTheme theme;

  static const _cardSize = Size(240, 150);

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<CommunityThemeController>();
    final imageUrl = theme.backgroundImageUrl;

    return AspectRatio(
      aspectRatio: _cardSize.aspectRatio,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final isHidden = controller.isHidden;
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FittedBox(
                  child: SizedBox.fromSize(
                    size: _cardSize,
                    child: CommunityThemePreview(
                      colorScheme: theme.colorScheme,
                      background: imageUrl == null || isHidden
                          ? null
                          : Image(
                              image: ResizeImage(
                                NetworkImage(imageUrl),
                                width: 1600,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                    ),
                  ),
                ),
              ),
              if (isHidden)
                CommunityThemeWarning(
                  reason: theme.contentWarning!,
                  onShow: controller.reveal,
                ),
            ],
          );
        },
      ),
    );
  }
}
