import 'package:flutter/material.dart';
import 'package:nmail_standard/controllers/compose_controller.dart';
import 'package:nmail_standard/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/utils/toast_helper.dart';

/// Pick a send date and time and store it as the pending schedule. This does
/// not send: delivery is queued only when the user presses the send button,
/// which schedules whenever [ComposeController.scheduledAt] is set.
Future<void> pickScheduleTime(BuildContext context) async {
  final l = AppLocalizations.of(context);
  final controller = ComposeController.to;
  final now = DateTime.now();
  final existing = controller.scheduledAt.value;
  final suggested = (existing != null && existing.isAfter(now))
      ? existing
      : now.add(const Duration(hours: 1));

  final date = await showDatePicker(
    context: context,
    initialDate: suggested,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(suggested),
  );
  if (time == null || !context.mounted) return;

  final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
  if (!at.isAfter(DateTime.now())) {
    ToastHelper.error(context, l.composeScheduleTimePast);
    return;
  }

  controller.scheduledAt.value = at;
}
