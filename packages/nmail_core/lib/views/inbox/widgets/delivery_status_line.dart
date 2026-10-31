import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/email_delivery_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/email_delivery_summary.dart';

/// The delivery of a sent email in its row, while it is still sending or once
/// a recipient did not get it.
class DeliveryStatusLine extends StatelessWidget {
  const DeliveryStatusLine({super.key, required this.delivery});

  final EmailDeliveryController delivery;

  @override
  Widget build(BuildContext context) {
    final summary = emailDeliverySummary(
      AppLocalizations.of(context),
      delivery,
    );
    if (summary == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Text(
      summary,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: delivery.hasFailed
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
