import 'package:flutter/material.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/views/email/email_controller.dart';

import 'recipient_avatar_view.dart';

class RecipientRowView extends StatelessWidget {
  const RecipientRowView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            l.emailRecipientTo,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        RecipientAvatarView(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            EmailController.to.recipientDisplayName,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
