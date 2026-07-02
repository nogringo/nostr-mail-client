import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail_client/controllers/compose_controller.dart';
import 'package:nostr_mail_client/l10n/generated/app_localizations.dart';
import 'package:nostr_mail_client/utils/toast_helper.dart';

class ScheduleSendButton extends StatelessWidget {
  const ScheduleSendButton({super.key});

  Future<void> _pickAndSchedule(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;
    final now = DateTime.now();
    final suggested = now.add(const Duration(hours: 1));

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

    final at = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!at.isAfter(DateTime.now())) {
      ToastHelper.error(context, l.composeScheduleTimePast);
      return;
    }

    await controller.firstSchedule(at);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;
    return Obx(
      () => IconButton(
        onPressed: controller.isSending.value
            ? null
            : () => _pickAndSchedule(context),
        icon: const Icon(Icons.schedule),
        tooltip: l.composeScheduleSend,
      ),
    );
  }
}
