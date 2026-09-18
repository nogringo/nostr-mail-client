import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class DohServerDialog extends StatelessWidget {
  const DohServerDialog({super.key, required this.controller});

  final TextEditingController controller;

  static bool _isValid(String value) {
    final server = value.trim();
    if (server.isEmpty) return true;
    final uri = Uri.tryParse(server);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isValid = _isValid(value.text);
        return AlertDialog(
          title: Text(l.settingsDohServer),
          content: SizedBox(
            width: 400,
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: SettingsController.defaultDohServer,
                helperText: l.settingsDohServerHelper,
                helperMaxLines: 3,
                errorText: isValid ? null : l.settingsDohServerInvalid,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            TextButton(
              onPressed: isValid
                  ? () => Navigator.pop(context, controller.text)
                  : null,
              child: Text(l.actionSave),
            ),
          ],
        );
      },
    );
  }
}
