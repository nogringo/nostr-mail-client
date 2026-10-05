import 'package:flutter/material.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/compose/widgets/schedule_send_button.dart';
import 'package:nmail_core/views/compose/widgets/send_button_menu.dart';

class BottomToolbarView extends StatelessWidget {
  const BottomToolbarView({super.key, required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SendButtonMenu(controller: controller),
          const SizedBox(width: 8),
          ScheduleSendButton(controller: controller),
          IconButton(
            onPressed: controller.pickAttachments,
            icon: const Icon(Icons.attach_file),
            tooltip: l.composeAttachFile,
          ),
        ],
      ),
    );
  }
}
