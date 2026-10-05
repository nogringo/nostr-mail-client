import 'package:flutter/material.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/schedule_picker.dart';

class ScheduleSendButton extends StatelessWidget {
  const ScheduleSendButton({super.key, required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      onPressed: controller.isSending
          ? null
          : () => pickScheduleTime(context, controller),
      icon: const Icon(Icons.schedule),
      tooltip: l.composeScheduleSend,
    );
  }
}
