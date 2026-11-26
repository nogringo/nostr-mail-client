import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../email_controller.dart';

class EmailNavigationButtons extends StatelessWidget {
  const EmailNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = EmailController.to;

    return ListenableBuilder(
      listenable: Listenable.merge([controller, GetIt.I<InboxController>()]),
      builder: (context, _) {
        final hasPrevious = controller.hasNeighbor(-1);
        final hasNext = controller.hasNeighbor(1);
        if (!hasPrevious && !hasNext) return const SizedBox.shrink();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up),
              tooltip: l.emailPrevious,
              onPressed: hasPrevious ? () => controller.openNeighbor(-1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              tooltip: l.emailNext,
              onPressed: hasNext ? () => controller.openNeighbor(1) : null,
            ),
          ],
        );
      },
    );
  }
}
