import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../email_controller.dart';

class EmailSourceCopyButton extends StatelessWidget {
  EmailSourceCopyButton({super.key});

  final _copied = false.obs;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<EmailController>(
      builder: (controller) {
        final source = controller.rawContent;
        return Obx(
          () => IconButton(
            icon: Icon(_copied.value ? Icons.check : Icons.copy),
            tooltip: l.actionCopy,
            onPressed: source == null ? null : () => _copy(source),
          ),
        );
      },
    );
  }

  void _copy(String source) {
    Clipboard.setData(ClipboardData(text: source));
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () => _copied.value = false);
  }
}
