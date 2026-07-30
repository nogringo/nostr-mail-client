import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/account_signer_kind.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';

class RemoveAccountDialog extends StatelessWidget {
  const RemoveAccountDialog({super.key, required this.pubkey});

  final String pubkey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final auth = Get.find<AuthController>();

    final metadata = Get.find<MetadataService>().of(pubkey).value;
    final name = metadata?.getBestName() ?? getAnonName(pubkey);
    final holdsPrivateKey =
        auth.signerKindOf(pubkey) == AccountSignerKind.privateKey;
    final isLastAccount = !auth.hasMultipleAccounts;

    return AlertDialog(
      title: Text(l.accountsRemoveTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.accountsRemoveMessage(name)),
          // Losing the only copy of the key is irreversible, so it gets the
          // error treatment. Being logged out is merely a consequence.
          if (holdsPrivateKey)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.accountsRemoveKeyWarning,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          if (isLastAccount)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(l.accountsRemoveLastWarning),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.actionRemove),
        ),
      ],
    );
  }
}
