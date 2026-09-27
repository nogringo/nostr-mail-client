import 'package:flutter/material.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Unfolds, folds and removes the email a reply quotes.
class QuoteActions extends StatelessWidget {
  final bool expanded;

  const QuoteActions({super.key, required this.expanded});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = ComposeController.to;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: controller.toggleQuote,
            icon: Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            iconAlignment: IconAlignment.end,
            label: Text(l.composeOriginalMessage),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: controller.removeQuote,
            icon: const Icon(Icons.close),
            label: Text(l.composeRemoveQuote),
          ),
        ],
      ),
    );
  }
}
