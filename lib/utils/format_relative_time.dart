import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import 'format_date.dart';

String formatRelativeTime(BuildContext context, DateTime date) {
  final l = AppLocalizations.of(context);
  final diff = DateTime.now().difference(date);

  if (diff.inMinutes < 1) return l.dateJustNow;
  if (diff.inHours < 1) return l.dateMinutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l.dateHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l.dateDaysAgo(diff.inDays);
  return formatDate(context, date);
}
