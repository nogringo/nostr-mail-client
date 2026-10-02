import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/share_theme_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/widgets/background_preset_visual.dart';
import 'community_theme_preview.dart';

class ShareThemeDialog extends StatelessWidget {
  const ShareThemeDialog({super.key, required this.controller});

  final ShareThemeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final customImage = controller.customImage;
    final presetVariant = controller.presetVariant;

    return AlertDialog(
      scrollable: true,
      title: Text(l.communityThemesShare),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            AspectRatio(
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
            TextField(
              controller: controller.titleController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l.communityThemesShareName,
              ),
              onSubmitted: (_) => _publish(context),
            ),
            Text(
              controller.hasBackgroundImage
                  ? l.communityThemesSharePublicWithImage
                  : l.communityThemesSharePublic,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
