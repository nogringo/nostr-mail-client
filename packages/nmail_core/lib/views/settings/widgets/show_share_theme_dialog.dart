import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/controllers/share_theme_controller.dart';
import 'share_theme_copy_dialog.dart';
import 'share_theme_dialog.dart';

/// Publishes the look on screen, unless it already is a community theme.
Future<void> showShareThemeDialog(BuildContext context) async {
  final applied = GetIt.I<SettingsController>().communityTheme.value;
  if (applied != null) {
    await showDialog<void>(
      context: context,
      builder: (_) => ShareThemeCopyDialog(address: applied),
    );
    return;
  }

  final controller = ShareThemeController(
    brightness: Theme.of(context).brightness,
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
      controller.dispose();
    } else {
      shown.completed.then((_) => controller.dispose());
    }
  }
}
