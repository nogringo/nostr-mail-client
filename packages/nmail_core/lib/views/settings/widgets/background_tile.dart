import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'background_gallery.dart';
import 'background_web_image.dart';
import 'settings_tile_label.dart';

/// Segmented row whose control is a gallery, so it stands taller than a
/// [ListTile] but keeps the group's surface and shape.
class BackgroundTile extends StatelessWidget {
  const BackgroundTile({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SettingsTileLabel(
                  icon: Icons.wallpaper_outlined,
                  label: l.settingsBackground,
                ),
              ),
              const SizedBox(height: 12),
              if (PlatformHelper.isNative)
                const BackgroundGallery()
              else
                const BackgroundWebImage(),
            ],
          ),
        ),
      ),
    );
  }
}
