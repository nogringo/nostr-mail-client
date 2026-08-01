import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/language_names.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<SettingsController>();

    return AlertDialog(
      title: Text(l.settingsLanguageDialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 320,
        child: Obx(
          () => SingleChildScrollView(
            child: RadioGroup<Locale?>(
              groupValue: controller.locale.value,
              onChanged: (locale) {
                controller.setLocale(locale);
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<Locale?>(
                    value: null,
                    title: Text(l.settingsLanguageSystem),
                  ),
                  for (final locale in pickableLocales)
                    RadioListTile<Locale?>(
                      value: locale,
                      title: Text(languageName(locale)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }
}
