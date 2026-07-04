import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/scheduled_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Actions shown in the toolbar while scheduled emails are selected, mirroring
/// [SelectionActionsBar]. The only bulk action is cancelling the send.
class ScheduledSelectionActionsBar extends StatelessWidget {
  const ScheduledSelectionActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<ScheduledController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: l.inboxSelectAll,
          onPressed: controller.selectAll,
        ),
        IconButton(
          icon: const Icon(Icons.cancel_schedule_send),
          tooltip: l.scheduledCancel,
          color: colorScheme.error,
          onPressed: controller.cancelSelected,
        ),
      ],
    );
  }
}
