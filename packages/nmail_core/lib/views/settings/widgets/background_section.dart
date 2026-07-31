import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'background_gallery.dart';
import 'background_web_image.dart';
import 'settings_tile_label.dart';

class BackgroundSection extends StatelessWidget {
  const BackgroundSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsTileLabel(
            icon: Icons.wallpaper_outlined,
            label: l.settingsBackground,
          ),
          const SizedBox(height: 8),
          if (PlatformHelper.isNative)
            const BackgroundGallery()
          else
            const BackgroundWebImage(),
        ],
      ),
    );
  }
}
