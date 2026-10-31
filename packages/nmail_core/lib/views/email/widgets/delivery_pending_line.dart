import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../email_controller.dart';
import 'delivery_details_sheet.dart';

/// A sent email still on its way, under its sender. A refusal shows in
/// [DeliveryBanner] instead.
class DeliveryPendingLine extends StatelessWidget {
  const DeliveryPendingLine({super.key});

  @override
  Widget build(BuildContext context) {
    final delivery = EmailController.to.delivery;
    if (delivery == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: delivery,
      builder: (context, _) {
        if (!delivery.isPending) return const SizedBox.shrink();
        final l = AppLocalizations.of(context);
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.emailDeliverySending,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showDeliveryDetails(context, delivery),
                child: Text(l.emailDeliveryDetails),
              ),
            ],
          ),
        );
      },
    );
  }
}
