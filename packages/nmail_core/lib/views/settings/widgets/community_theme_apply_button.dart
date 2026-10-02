import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_theme_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/community_theme.dart';

class CommunityThemeApplyButton extends StatelessWidget {
  const CommunityThemeApplyButton({super.key, required this.theme});

  final CommunityTheme theme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<CommunityThemeController>();
    final settings = Get.find<SettingsController>();

    return Obx(() {
      if (settings.communityTheme.value == theme.address) {
        return FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check),
          label: Text(l.communityThemeCurrent),
        );
      }

      final isApplying = controller.isApplying.value;
      return FilledButton.icon(
        onPressed: isApplying ? null : () => controller.apply(context),
        icon: isApplying
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.format_paint_outlined),
        label: Text(l.communityThemeApply),
      );
    });
  }
}
