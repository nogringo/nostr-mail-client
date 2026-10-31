import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// One relay or Blossom server of a sent email, and how it answered.
class DeliveryUrlRow extends StatelessWidget {
  const DeliveryUrlRow({
    super.key,
    required this.label,
    required this.delivery,
    required this.index,
    required this.count,
  });

  final String label;
  final UrlDelivery delivery;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (String status, Color color) = switch (delivery.status) {
      DeliveryStatus.delivered => (
        l.emailDeliveryAccepted,
        colorScheme.primary,
      ),
      DeliveryStatus.pending => (
        l.emailDeliveryWaiting,
        colorScheme.onSurfaceVariant,
      ),
      DeliveryStatus.failed => (l.emailDeliveryRefused, colorScheme.error),
    };
    final error = delivery.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 56,
        title: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: error == null
            ? null
            : Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: delivery.status == DeliveryStatus.failed
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
        trailing: Text(
          status,
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}
