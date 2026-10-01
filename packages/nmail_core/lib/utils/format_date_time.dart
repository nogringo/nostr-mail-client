import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

String formatDateTime(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMd(locale).add_Hm().format(date);
}

String formatSyncDate(BuildContext context, DateTime date) {
  if (date.millisecondsSinceEpoch == 0) {
    return AppLocalizations.of(context).syncStatusBeginningOfTime;
  }
  return formatDateTime(context, date.toLocal());
}
