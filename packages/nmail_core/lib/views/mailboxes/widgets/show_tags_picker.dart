import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/tags_picker_controller.dart';
import 'tags_picker_dialog.dart';

/// The tags to add to and take off [emails], null when dismissed.
Future<TagChanges?> showTagsPicker(
  BuildContext context, {
  required List<EmailSummary> emails,
}) async {
  final tag = UniqueKey().toString();
  final controller = Get.put(TagsPickerController(emails), tag: tag);
  try {
    return await showDialog<TagChanges>(
      context: context,
      builder: (_) => TagsPickerDialog(controller: controller),
    );
  } finally {
    Get.delete<TagsPickerController>(tag: tag);
  }
}
