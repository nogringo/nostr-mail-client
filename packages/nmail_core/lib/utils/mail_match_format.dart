import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// The entries of a comma-separated field, trimmed, or null when it holds
/// none: an absent field does not constrain a match.
List<String>? parseMatchList(String text) {
  final entries = [
    for (final part in text.split(','))
      if (part.trim().isNotEmpty) part.trim(),
  ];
  return entries.isEmpty ? null : entries;
}

String formatMatchList(List<String>? entries) => entries?.join(', ') ?? '';

/// The condition the form fields describe, or null when every one is empty.
/// Built on [original] so the fields this version does not know survive.
MailMatch? buildMailMatch({
  required String from,
  required String subject,
  required bool? hasAttachment,
  MailMatch? original,
}) {
  final fromEntries = parseMatchList(from);
  final subjectEntries = parseMatchList(subject);
  if (fromEntries == null && subjectEntries == null && hasAttachment == null) {
    return null;
  }
  return (original ?? const MailMatch()).copyWith(
    from: fromEntries,
    subject: subjectEntries,
    hasAttachment: hasAttachment,
    clearFrom: fromEntries == null,
    clearSubject: subjectEntries == null,
    clearHasAttachment: hasAttachment == null,
  );
}

/// One line per condition, joined with semicolons since the values of one
/// condition are already joined with commas.
String describeMailMatch(AppLocalizations l, MailMatch match) => [
  if (match.from != null) l.mailboxRuleSummaryFrom(formatMatchList(match.from)),
  if (match.subject != null)
    l.mailboxRuleSummarySubject(formatMatchList(match.subject)),
  if (match.hasAttachment == true) l.mailboxRuleSummaryWithAttachment,
  if (match.hasAttachment == false) l.mailboxRuleSummaryWithoutAttachment,
].join('; ');
