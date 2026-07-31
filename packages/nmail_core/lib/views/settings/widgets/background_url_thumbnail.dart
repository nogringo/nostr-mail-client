import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'background_remove_badge.dart';
import 'background_thumbnail.dart';

/// The single remote background web builds can hold, always the selected one.
class BackgroundUrlThumbnail extends StatelessWidget {
  const BackgroundUrlThumbnail({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<BackgroundsController>();

    return BackgroundThumbnail(
      label: l.settingsBackgroundRemoveLabel,
      isSelected: true,
      onTap: () => controller.select(null),
      badge: BackgroundRemoveBadge(
        label: l.settingsBackgroundRemoveLabel,
        onTap: () => controller.select(null),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: colorScheme.errorContainer,
          child: Icon(Icons.broken_image, color: colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}
