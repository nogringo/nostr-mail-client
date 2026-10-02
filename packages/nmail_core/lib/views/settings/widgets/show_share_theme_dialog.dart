import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/controllers/share_theme_controller.dart';
import 'share_theme_copy_dialog.dart';
import 'share_theme_dialog.dart';

/// Publishes the look on screen, unless it already is a community theme.
Future<void> showShareThemeDialog(BuildContext context) async {
  final applied = Get.find<SettingsController>().communityTheme.value;
  if (applied != null) {
    await showDialog<void>(
      context: context,
      builder: (_) => ShareThemeCopyDialog(address: applied),
    );
    return;
  }

  final tag = UniqueKey().toString();
  final controller = Get.put(
    ShareThemeController(brightness: Theme.of(context).brightness),
    tag: tag,
  );
  ModalRoute<Object?>? route;
  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        route = ModalRoute.of(dialogContext);
        return ShareThemeDialog(controller: controller);
      },
    );
  } finally {
    // The text field keeps building through the exit animation, so its
    // controller is disposed once the route is gone, not on pop.
    final shown = route;
    if (shown == null) {
      Get.delete<ShareThemeController>(tag: tag);
    } else {
      shown.completed.then((_) => Get.delete<ShareThemeController>(tag: tag));
    }
  }
}
