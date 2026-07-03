import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Small status label shown next to a scheduled email's send time. Renders
/// nothing for the ordinary pending/scheduled states, where the send time
/// already tells the whole story.
class ScheduledStatusChip extends StatelessWidget {
  final ScheduledEmailStatus status;

  const ScheduledStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final (String label, Color color) = switch (status) {
      ScheduledEmailStatus.published => (
        l.scheduledStatusSent,
        colorScheme.primary,
      ),
      ScheduledEmailStatus.failed => (
        l.scheduledStatusFailed,
        colorScheme.error,
      ),
      ScheduledEmailStatus.error => (l.scheduledStatusError, colorScheme.error),
      _ => ('', colorScheme.onSurfaceVariant),
    };
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}
