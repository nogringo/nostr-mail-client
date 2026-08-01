import 'package:flutter/widgets.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

// Each locale is named in its own script so users who can't currently read the
// app's strings still recognise their language. Ordered the way users expect:
// Latin-script alphabetical by native name, then non-Latin scripts grouped at
// the end (alphabetical by English language name).
const _languageNames = <String, String>{
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

const _locales = <Locale>[
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

/// Locales the picker offers, in display order rather than the ISO-code order
/// of [AppLocalizations.supportedLocales].
List<Locale> get pickableLocales {
  final supported = AppLocalizations.supportedLocales.map(localeKey).toSet();
  return _locales
      .where((locale) => supported.contains(localeKey(locale)))
      .toList();
}

String languageName(Locale locale) =>
    _languageNames[localeKey(locale)] ?? locale.toString();

String localeKey(Locale locale) {
  final countryCode = locale.countryCode;
  if (countryCode == null || countryCode.isEmpty) return locale.languageCode;

  return '${locale.languageCode}_$countryCode';
}
