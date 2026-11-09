import 'package:flutter/widgets.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Strings in the device language, for text the OS shows outside the app.
AppLocalizations systemAppLocalizations() => lookupAppLocalizations(
  basicLocaleListResolution(
    WidgetsBinding.instance.platformDispatcher.locales,
    AppLocalizations.supportedLocales,
  ),
);
