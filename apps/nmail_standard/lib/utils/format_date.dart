import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

String formatDate(BuildContext context, DateTime date) {
  final l = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) {
    return DateFormat.Hm(locale).format(date);
  } else if (diff.inDays == 1) {
    return l.dateYesterday;
  } else if (diff.inDays < 7) {
    return DateFormat.E(locale).format(date);
  } else {
    return DateFormat.Md(locale).format(date);
  }
}

/// Absolute date and time for a future moment (e.g. a scheduled send time),
/// where a relative "yesterday/today" label would be misleading.
String formatDateTime(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.MMMd(locale).add_jm().format(date);
}
