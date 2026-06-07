import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';

String formatDateTime(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMd(locale).add_Hm().format(date);
}

String formatSyncTimestamp(BuildContext context, int? timestamp) {
  if (timestamp == null) return '-';

  final l = AppLocalizations.of(context);
  if (timestamp == 0) return l.syncStatusBeginningOfTime;

  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return formatDateTime(context, date);
}
