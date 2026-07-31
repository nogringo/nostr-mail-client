import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/backgrounds_controller.dart';
import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'background_remove_badge.dart';
import 'background_thumbnail.dart';

class BackgroundFileThumbnail extends StatelessWidget {
  const BackgroundFileThumbnail({super.key, required this.file});

  final File file;

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
    await controller.deleteImage(context, file);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = Get.find<SettingsController>();

    return Obx(
      () => BackgroundThumbnail(
        label: l.settingsBackgroundSelectLabel,
        isSelected: settings.backgroundImage.value == file.path,
        onTap: () => Get.find<BackgroundsController>().select(file.path),
        onLongPress: () => _confirmDelete(context),
        badge: BackgroundRemoveBadge(
          label: l.settingsBackgroundDeleteLabel,
          onTap: () => _confirmDelete(context),
        ),
        child: Image.file(file, fit: BoxFit.cover),
      ),
    );
  }
}
