import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';

/// Small label telling where a scheduled email stands with the DVM.
class ScheduledStatusChip extends StatelessWidget {
  final ScheduledDisplayStatus status;

  const ScheduledStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final (String label, Color color) = switch (status) {
      ScheduledDisplayStatus.pending => (
        l.scheduledStatusPending,
        colorScheme.onSurfaceVariant,
      ),
      ScheduledDisplayStatus.scheduled => (
        l.scheduledStatusScheduled,
        colorScheme.primary,
      ),
      ScheduledDisplayStatus.sending => (
        l.scheduledStatusSending,
        colorScheme.primary,
      ),
      ScheduledDisplayStatus.overdue => (
        l.scheduledStatusOverdue,
        colorScheme.error,
      ),
      ScheduledDisplayStatus.failed => (
        l.scheduledStatusFailed,
        colorScheme.error,
      ),
      ScheduledDisplayStatus.error => (
        l.scheduledStatusError,
        colorScheme.error,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
