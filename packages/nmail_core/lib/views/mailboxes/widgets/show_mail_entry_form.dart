import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'mail_entry_form_page.dart';
import 'mail_entry_form_sheet.dart';

/// Creates a folder or a tag, or edits [entry]. Returns the saved entry, or
/// null when the form was dismissed.
Future<MailEntry?> showMailEntryForm(
  BuildContext context, {
  required MailEntryKind kind,
  MailEntry? entry,
}) async {
  final tag = UniqueKey().toString();
  final controller = Get.put(
    MailEntryFormController(kind: kind, entry: entry),
    tag: tag,
  );
  ModalRoute<Object?>? route;
  try {
    return await showDialog<MailEntry>(
      context: context,
      builder: (dialogContext) {
        route = ModalRoute.of(dialogContext);
        return ResponsiveHelper.isNotMobile(context)
            ? Dialog(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: MailEntryFormSheet(controller: controller),
                ),
              )
            : Dialog.fullscreen(
                child: MailEntryFormPage(controller: controller),
              );
      },
    );
  } finally {
    // The fields keep building through the exit animation, so their text
    // controllers are disposed once the route is gone, not on pop.
    final shown = route;
    if (shown == null) {
      Get.delete<MailEntryFormController>(tag: tag);
    } else {
      shown.completed.then(
        (_) => Get.delete<MailEntryFormController>(tag: tag),
      );
    }
  }
}
