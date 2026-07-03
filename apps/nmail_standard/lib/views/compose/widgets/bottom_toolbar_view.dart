import 'package:flutter/material.dart';
import 'package:nmail_standard/controllers/compose_controller.dart';
import 'package:nmail_standard/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/views/compose/widgets/schedule_send_button.dart';
import 'package:nmail_standard/views/compose/widgets/send_button_menu.dart';

class BottomToolbarView extends StatelessWidget {
  const BottomToolbarView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const SendButtonMenu(),
          const SizedBox(width: 8),
          const ScheduleSendButton(),
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
