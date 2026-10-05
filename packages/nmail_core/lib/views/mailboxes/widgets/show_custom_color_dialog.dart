import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/custom_color_controller.dart';
import 'custom_color_dialog.dart';

/// The picked color as `#RRGGBB`, or null when dismissed.
Future<String?> showCustomColorDialog(
  BuildContext context, {
  required Color initial,
}) async {
  final controller = CustomColorController(initial);
  ModalRoute<Object?>? route;
  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        route = ModalRoute.of(dialogContext);
        return CustomColorDialog(controller: controller);
      },
    );
  } finally {
    // See showMailEntryForm: the hex field outlives the pop.
    final shown = route;
    if (shown == null) {
      controller.dispose();
    } else {
      shown.completed.then((_) => controller.dispose());
    }
  }
}
