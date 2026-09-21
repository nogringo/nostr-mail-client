import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/startup_error_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class StartupErrorCopyButton extends StatelessWidget {
  const StartupErrorCopyButton({super.key, required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<StartupErrorController>(
      init: StartupErrorController(),
      builder: (controller) => TextButton.icon(
        onPressed: () => controller.copyDetails(details),
        icon: Icon(controller.hasCopied ? Icons.check : Icons.copy),
        label: Text(
          controller.hasCopied ? l.authCopied : l.startupErrorCopyDetails,
        ),
      ),
    );
  }
}
