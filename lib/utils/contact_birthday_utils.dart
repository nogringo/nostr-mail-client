import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A contact birthday, where the year is optional (unknown).
class ContactBirthday {
  /// The year, or `null` when only the day and month are known.
  final int? year;
  final int month;
  final int day;

  const ContactBirthday({this.year, required this.month, required this.day});

  @override
  bool operator ==(Object other) =>
      other is ContactBirthday &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'ContactBirthday(year: $year, month: $month, day: $day)';
}

/// Formats a birthday for display, in full words and localized.
///
/// Example: `11 juin` (year unknown) or `11 juin 1990` (year known).
String formatContactBirthdayForDisplay(
  BuildContext context,
  ContactBirthday birthday,
) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  // Use a fixed leap year so February 29 stays valid when the year is unknown.
  final date = DateTime(birthday.year ?? 2000, birthday.month, birthday.day);
  final format = birthday.year == null
      ? DateFormat.MMMMd(locale)
      : DateFormat.yMMMMd(locale);
  return format.format(date);
}
