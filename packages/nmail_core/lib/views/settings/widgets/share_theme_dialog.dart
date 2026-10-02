import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/share_theme_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/widgets/background_preset_visual.dart';
import 'community_theme_preview.dart';
import 'share_theme_nsfw_tile.dart';

class ShareThemeDialog extends StatelessWidget {
  const ShareThemeDialog({super.key, required this.controller});

  final ShareThemeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customImage = controller.customImage;
    final presetVariant = controller.presetVariant;

    const gutter = EdgeInsets.symmetric(horizontal: 24);

    return AlertDialog(
      scrollable: true,
      title: Text(l.communityThemesShare),
      // The switch tile runs edge to edge, so the gutter is per child.
      contentPadding: const EdgeInsets.only(top: 16, bottom: 24),
      content: SizedBox(
        width: 448,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Padding(
              padding: gutter,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CommunityThemePreview(
                    colorScheme: controller.colorScheme,
                    background: customImage != null
                        ? Image(image: customImage, fit: BoxFit.cover)
                        : presetVariant != null
                        ? BackgroundPresetVisual(
                            variant: presetVariant,
                            animate: false,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Padding(
              padding: gutter,
              child: TextField(
                controller: controller.titleController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l.communityThemesShareName,
                ),
                onSubmitted: (_) => _publish(context),
              ),
            ),
            ShareThemeNsfwTile(controller: controller, gutter: gutter),
            Padding(
              padding: gutter,
              child: Text(
                controller.hasBackgroundImage
                    ? l.communityThemesSharePublicWithImage
                    : l.communityThemesSharePublic,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        Obx(
          () => FilledButton(
            onPressed:
                controller.title.value.isEmpty || controller.isPublishing.value
                ? null
                : () => _publish(context),
            child: controller.isPublishing.value
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.communityThemesShareAction),
          ),
        ),
      ],
    );
  }

  Future<void> _publish(BuildContext context) async {
    if (controller.title.value.isEmpty || controller.isPublishing.value) {
      return;
    }
    final l = AppLocalizations.of(context);
    try {
      await controller.publish();
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.communityThemesShareError);
      }
    }
  }
}
