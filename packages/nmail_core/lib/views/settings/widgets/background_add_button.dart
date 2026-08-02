import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'background_thumbnail.dart';

enum _BackgroundSource { file, url }

class BackgroundAddButton extends StatelessWidget {
  const BackgroundAddButton({super.key});

  Future<void> _addBackground(BuildContext context) async {
    final controller = Get.find<BackgroundsController>();

    final source = await _askSource(context);
    if (source == null || !context.mounted) return;

    if (source == _BackgroundSource.url) {
      final url = await _askUrl(context);
      if (url == null || !context.mounted) return;
      await controller.addFromUrl(context, url);
      return;
    }

    final picked = await controller.pickImage();
    if (picked == null || !context.mounted) return;

    if (!PlatformHelper.isNative) {
      final confirmed = await _confirmUpload(context);
      if (!confirmed || !context.mounted) return;
    }

    await controller.addPickedImage(context, picked);
  }

  Future<_BackgroundSource?> _askSource(BuildContext context) {
    final l = AppLocalizations.of(context);

    return showDialog<_BackgroundSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsBackgroundDialogTitle),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.image_outlined),
              title: Text(l.settingsBackgroundSelectFile),
              onTap: () => Navigator.pop(context, _BackgroundSource.file),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Icons.link),
              title: Text(l.settingsBackgroundPasteUrl),
              onTap: () => Navigator.pop(context, _BackgroundSource.url),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
        ],
      ),
    );
  }

  /// An empty result clears the background.
  Future<String?> _askUrl(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentValue = Get.find<SettingsController>().backgroundImage.value;
    final inputController = TextEditingController(
      text:
          PlatformHelper.isNative ||
              !BackgroundPreset.isCustomImageValue(currentValue)
          ? ''
          : currentValue,
    );

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsBackgroundUrlTitle),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: inputController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l.settingsBackgroundUrlHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) => Navigator.pop(context, value.trim()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, inputController.text.trim()),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmUpload(BuildContext context) async {
    final l = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsBackgroundUploadTitle),
        content: Text(l.settingsBackgroundUploadWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionUpload),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<BackgroundsController>();

    return Obx(() {
      final isBusy = controller.isBusy.value;
      return BackgroundThumbnail(
        label: l.settingsBackgroundAddLabel,
        onTap: isBusy ? null : () => _addBackground(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isBusy
              ? const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(Icons.add, color: colorScheme.onSurfaceVariant),
        ),
      );
    });
  }
}
