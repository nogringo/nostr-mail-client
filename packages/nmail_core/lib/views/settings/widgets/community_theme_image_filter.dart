import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class CommunityThemeImageFilter extends StatelessWidget {
  const CommunityThemeImageFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<CommunityThemesController>();

    return Obx(
      () => SegmentedButton<bool?>(
        segments: [
          ButtonSegment(value: null, label: Text(l.communityThemesFilterAll)),
          ButtonSegment(
            value: true,
            icon: const Icon(Icons.image_outlined),
            label: Text(l.communityThemesWithImage),
          ),
          ButtonSegment(
            value: false,
            icon: const Icon(Icons.hide_image_outlined),
            label: Text(l.communityThemesWithoutImage),
          ),
        ],
        selected: {controller.hasImage.value},
        showSelectedIcon: false,
        onSelectionChanged: (selection) =>
            controller.hasImage.value = selection.single,
      ),
    );
  }
}
