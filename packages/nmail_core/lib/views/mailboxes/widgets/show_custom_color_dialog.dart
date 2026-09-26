import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/custom_color_controller.dart';
import 'custom_color_dialog.dart';

/// The picked color as `#RRGGBB`, or null when dismissed.
Future<String?> showCustomColorDialog(
  BuildContext context, {
  required Color initial,
}) async {
  final tag = UniqueKey().toString();
  final controller = Get.put(CustomColorController(initial), tag: tag);
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
      Get.delete<CustomColorController>(tag: tag);
    } else {
      shown.completed.then((_) => Get.delete<CustomColorController>(tag: tag));
    }
  }
}
