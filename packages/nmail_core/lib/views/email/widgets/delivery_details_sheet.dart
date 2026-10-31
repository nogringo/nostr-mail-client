import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/email_delivery_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'recipient_delivery_section.dart';

/// Mobile (<600px): bottom sheet. Desktop: centered dialog.
Future<void> showDeliveryDetails(
  BuildContext context,
  EmailDeliveryController delivery,
) {
  if (MediaQuery.sizeOf(context).width < 600) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          SafeArea(top: false, child: DeliveryDetailsSheet(delivery: delivery)),
    );
  }

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: DeliveryDetailsSheet(delivery: delivery, isDialog: true),
      ),
    ),
  );
}

/// A sent email recipient by recipient, updated as the relays and servers
/// answer.
class DeliveryDetailsSheet extends StatelessWidget {
  const DeliveryDetailsSheet({
    super.key,
    required this.delivery,
    this.isDialog = false,
  });

  final EmailDeliveryController delivery;

  /// A dialog closes with a button, a sheet with its drag handle.
  final bool isDialog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: delivery,
      builder: (context, _) {
        final selfCopy = delivery.delivery?.selfCopy;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDialog) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.emailDeliveryTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const CloseButton(),
                  ],
                ),
              ),
              const Divider(height: 1),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Text(
                  l.emailDeliveryTitle,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  for (final recipient in delivery.recipients)
                    RecipientDeliverySection(recipient: recipient),
                  if (selfCopy != null)
                    RecipientDeliverySection(
                      recipient: selfCopy,
                      isSelfCopy: true,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
