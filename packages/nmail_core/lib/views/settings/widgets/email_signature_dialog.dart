import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class EmailSignatureDialog extends StatelessWidget {
  const EmailSignatureDialog({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.settingsEmailSignature),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          decoration: InputDecoration(hintText: l.settingsEmailSignatureHint),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(l.actionSave),
        ),
      ],
    );
  }
}
