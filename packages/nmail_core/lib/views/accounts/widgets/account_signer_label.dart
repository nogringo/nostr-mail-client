import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/account_signer_kind.dart';

/// How an account signs, spelled out. The icon only helps scanning, the words
/// carry the meaning. Both take the colour of the surrounding text so they stay
/// legible on the active account's fill.
class AccountSignerLabel extends StatelessWidget {
  const AccountSignerLabel({super.key, required this.kind});

  final AccountSignerKind kind;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = DefaultTextStyle.of(context).style.color;

    return Row(
      children: [
        Icon(
          switch (kind) {
            AccountSignerKind.privateKey => Icons.key,
            AccountSignerKind.browserExtension => Icons.extension,
            AccountSignerKind.signerApp => Icons.smartphone,
            AccountSignerKind.bunker => Icons.cloud_outlined,
            AccountSignerKind.external => Icons.vpn_key,
          },
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            switch (kind) {
              AccountSignerKind.privateKey => l.accountSignerPrivateKey,
              AccountSignerKind.browserExtension => l.accountSignerExtension,
              AccountSignerKind.signerApp => l.accountSignerApp,
              AccountSignerKind.bunker => l.accountSignerBunker,
              AccountSignerKind.external => l.accountSignerExternal,
            },
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
