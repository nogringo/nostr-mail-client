import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_standard/controllers/compose_controller.dart';
import 'package:nmail_standard/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/utils/schedule_picker.dart';

class ScheduleSendButton extends StatelessWidget {
  const ScheduleSendButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;
    return Obx(
      () => IconButton(
        onPressed: controller.isSending.value
            ? null
            : () => pickScheduleTime(context),
        icon: const Icon(Icons.schedule),
        tooltip: l.composeScheduleSend,
      ),
    );
  }
}
