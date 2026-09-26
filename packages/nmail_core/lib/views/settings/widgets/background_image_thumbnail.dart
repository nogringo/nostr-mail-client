import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'background_remove_badge.dart';
import 'background_thumbnail.dart';

class BackgroundImageThumbnail extends StatelessWidget {
  const BackgroundImageThumbnail({super.key, required this.value});

  final String value;

  Future<void> _confirmDelete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final controller = Get.find<BackgroundsController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsBackgroundDeleteTitle),
        content: Text(l.settingsBackgroundDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await controller.deleteImage(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Get.find<SettingsController>();

    return Obx(
      () => BackgroundThumbnail(
        label: l.settingsBackgroundSelectLabel,
        isSelected: settings.backgroundImage.value == value,
        onTap: () => Get.find<BackgroundsController>().select(value),
        onLongPress: () => _confirmDelete(context),
        badge: BackgroundRemoveBadge(
          label: l.settingsBackgroundDeleteLabel,
          onTap: () => _confirmDelete(context),
        ),
        child: Image(
          image: BackgroundPreset.customImage(value),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}
