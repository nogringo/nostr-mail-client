import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/email_delivery_summary.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import '../email_controller.dart';
import 'delivery_details_sheet.dart';

/// A sent email some recipients did not get, kept in sight above the
/// scrolling message.
class DeliveryBanner extends StatelessWidget {
  const DeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final delivery = EmailController.to.delivery;
    if (delivery == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: delivery,
      builder: (context, _) {
        if (!delivery.hasFailed) return const SizedBox.shrink();
        final l = AppLocalizations.of(context);
        final colorScheme = Theme.of(context).colorScheme;

        final actions = [
          TextButton(
            onPressed: () => showDeliveryDetails(context, delivery),
            child: Text(l.emailDeliveryDetails),
          ),
          TextButton(
            onPressed: delivery.retry,
            child: Text(l.emailDeliveryRetry),
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= ResponsiveBreakpoints.mobile;

            return MaterialBanner(
              leading: Icon(Icons.error_outline, color: colorScheme.error),
              content: ListenableBuilder(
                listenable: emailDeliverySummaryListenable(delivery),
                builder: (context, _) =>
                    Text(emailNotDeliveredSummary(l, delivery)),
              ),
              // MaterialBanner stays on one row only with a single action.
              actions: isWide
                  ? [OverflowBar(spacing: 8, children: actions)]
                  : actions,
            );
          },
        );
      },
    );
  }
}
