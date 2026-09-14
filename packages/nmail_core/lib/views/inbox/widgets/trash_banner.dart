import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'delete_permanently_dialog.dart';

class TrashBanner extends GetView<InboxController> {
  const TrashBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Obx(() {
      if (controller.currentFolder.value != MailFolder.trash ||
          controller.isSearching ||
          controller.emails.isEmpty) {
        return const SizedBox.shrink();
      }

      final isDeleting = controller.isDeletingFromTrash.value;
      final trashCount = controller.emails.length;
      final oldCount = controller.oldEmailsCount.value;

      final actions = [
        if (oldCount > 0)
          TextButton(
            onPressed: isDeleting ? null : () => _deleteOld(context, oldCount),
            child: Text(l.inboxDeleteOlderThan30Days),
          ),
        TextButton(
          onPressed: isDeleting ? null : () => _empty(context, trashCount),
          child: Text(l.inboxEmptyTrashAction),
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= ResponsiveBreakpoints.mobile;

          return MaterialBanner(
            leading: isDeleting
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            content: Text(l.inboxTrashCount(trashCount)),
            // MaterialBanner stays on one row only with a single action.
            actions: isWide
                ? [OverflowBar(spacing: 8, children: actions)]
                : actions,
          );
        },
      );
    });
  }

  Future<void> _deleteOld(BuildContext context, int oldCount) {
    final l = AppLocalizations.of(context);
    return DeletePermanentlyDialog.confirmAndDelete(
      context,
      title: l.inboxDeleteOldEmailsTitle,
      message: l.inboxDeleteOldEmailsMessage(oldCount),
      confirmLabel: l.actionDelete,
      delete: controller.deleteOldEmails,
    );
  }

  Future<void> _empty(BuildContext context, int trashCount) {
    final l = AppLocalizations.of(context);
    return DeletePermanentlyDialog.confirmAndDelete(
      context,
      title: l.inboxEmptyTrashTitle,
      message: l.inboxEmptyTrashMessage(trashCount),
      confirmLabel: l.inboxEmptyTrashAction,
      delete: controller.emptyTrash,
    );
  }
}
