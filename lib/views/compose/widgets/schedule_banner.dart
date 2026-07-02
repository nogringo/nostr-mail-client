import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail_client/controllers/compose_controller.dart';
import 'package:nostr_mail_client/l10n/generated/app_localizations.dart';
import 'package:nostr_mail_client/utils/format_date.dart';
import 'package:nostr_mail_client/utils/schedule_picker.dart';

/// Shows the pending send time above the compose fields when a schedule is set,
/// so the user can see it, tap to change it, or clear it to send now instead.
class ScheduleBanner extends StatelessWidget {
  const ScheduleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final at = controller.scheduledAt.value;
      if (at == null) return const SizedBox.shrink();

      return Material(
        color: colorScheme.secondaryContainer,
        child: ListTile(
          iconColor: colorScheme.onSecondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
          leading: const Icon(Icons.schedule),
          title: Text(l.scheduledSendsAt(formatDateTime(context, at))),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            tooltip: l.composeScheduleClear,
            onPressed: () => controller.scheduledAt.value = null,
          ),
          onTap: () => pickScheduleTime(context),
        ),
      );
    });
  }
}
