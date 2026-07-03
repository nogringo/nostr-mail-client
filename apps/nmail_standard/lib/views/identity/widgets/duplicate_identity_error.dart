import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class DuplicateIdentityError extends StatelessWidget {
  const DuplicateIdentityError({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, size: 18, color: colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l.createIdentityAlreadyExists,
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}
