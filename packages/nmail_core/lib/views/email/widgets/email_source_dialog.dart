import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'email_source_content.dart';
import 'email_source_copy_button.dart';

/// Mobile (<600px): bottom sheet. Desktop: centered dialog.
Future<void> showEmailSourceDialog(BuildContext context) {
  if (MediaQuery.sizeOf(context).width < 600) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const SafeArea(child: EmailSourceDialog()),
    );
  }

  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: const EmailSourceDialog(),
      ),
    ),
  );
}

class EmailSourceDialog extends StatelessWidget {
  const EmailSourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 8, 12),
          child: Row(
            children: [
              Icon(Icons.code, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.emailActionViewSource,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              EmailSourceCopyButton(),
              const CloseButton(),
            ],
          ),
        ),
        const Divider(height: 1),
        const Flexible(child: EmailSourceContent()),
      ],
    );
  }
}
