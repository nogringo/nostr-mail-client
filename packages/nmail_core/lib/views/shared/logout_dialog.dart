import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key, required this.pubkey});

  final String pubkey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(l.logoutDialogTitle),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NostrAvatar(pubkey: pubkey),
                const SizedBox(width: 12),
                Expanded(
                  child: NostrDisplayName(
                    pubkey: pubkey,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(l.logoutDialogMessage),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: Text(l.actionLogOut),
        ),
      ],
    );
  }
}
