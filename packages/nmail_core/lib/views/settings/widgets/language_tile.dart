import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  // Each locale shown in its own native script so users who can't currently
  // read the app's strings still recognise their language. Ordered the way
  // users expect: Latin-script alphabetical by native name, then non-Latin
  // scripts grouped at the end (alphabetical by English language name).
  static const _languageNames = <String, String>{
    'de': 'Deutsch',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português (Portugal)',
    'pt_BR': 'Português (Brasil)',
    'fi': 'Suomi',
    'zh': '中文',
    'ja': '日本語',
    'ru': 'Русский',
  };

  static const _locales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('fi'),
    Locale('zh'),
    Locale('ja'),
    Locale('ru'),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<SettingsController>();

    return Obx(() {
      final current = controller.locale.value;
      final subtitle = current == null
          ? l.settingsLanguageSystem
          : _languageNames[_localeKey(current)] ?? current.toString();
      return ListTile(
        leading: const Icon(Icons.translate),
        title: Text(l.settingsLanguage),
        subtitle: Text(subtitle),
        onTap: () => _showLanguageDialog(context, controller),
      );
    });
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsController controller,
  ) {
    final l = AppLocalizations.of(context);
    // Iterate _languageNames (ordered) rather than supportedLocales (sorted by
    // ISO code) so the picker shows entries in the order users expect.
    final supportedKeys = AppLocalizations.supportedLocales
        .map(_localeKey)
        .toSet();
    final supported = _locales
        .where((locale) => supportedKeys.contains(_localeKey(locale)))
        .toList();

    Get.dialog(
      AlertDialog(
        title: Text(l.settingsLanguageDialogTitle),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        content: SizedBox(
          width: 320,
          child: Obx(() {
            final current = controller.locale.value;
            return SingleChildScrollView(
              child: RadioGroup<Locale?>(
                groupValue: current,
                onChanged: (value) {
                  controller.setLocale(value);
                  Get.back();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<Locale?>(
                      value: null,
                      title: Text(l.settingsLanguageSystem),
                    ),
                    for (final locale in supported)
                      RadioListTile<Locale?>(
                        value: locale,
                        title: Text(
                          _languageNames[_localeKey(locale)] ??
                              locale.toString(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l.actionCancel)),
        ],
      ),
    );
  }

  static String _localeKey(Locale locale) {
    final countryCode = locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return locale.languageCode;
    }

    return '${locale.languageCode}_$countryCode';
  }
}
