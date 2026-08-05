import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/delete_account_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'package:nmail_core/widgets/nostr_display_name.dart';

/// Confirms the deletion and runs it. Pops the id of the queued request to
/// vanish, or null when the user backed out or the signer refused.
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key, required this.pubkey});

  /// Fixed at open time: the wipe clears the active account halfway through,
  /// and the dialog must keep naming the account it is deleting.
  final String pubkey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confirmWord = l.settingsDeleteAccountConfirmWord;

    return GetBuilder<DeleteAccountController>(
      init: DeleteAccountController(),
      builder: (controller) {
        final isDeleting = controller.isDeleting;
        final canDelete = controller.confirms(confirmWord) && !isDeleting;

        return PopScope(
          canPop: !isDeleting,
          child: AlertDialog(
            title: Text(l.settingsDeleteAccountTitle),
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
                    child: Text(l.settingsDeleteAccountMessage),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      l.settingsDeleteAccountWarning,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: TextField(
                      controller: controller.confirmation,
                      enabled: !isDeleting,
                      autofocus: true,
                      autocorrect: false,
                      onSubmitted: (_) {
                        if (canDelete) _delete(context, controller);
                      },
                      decoration: InputDecoration(
                        labelText: l.settingsDeleteAccountConfirmLabel(
                          confirmWord,
                        ),
                      ),
                    ),
                  ),
                  if (controller.hasFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        l.settingsDeleteAccountSignFailed,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () => Navigator.pop(context, null),
                child: Text(l.actionCancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                onPressed: canDelete
                    ? () => _delete(context, controller)
                    : null,
                child: isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.actionDelete),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    DeleteAccountController controller,
  ) async {
    final requestId = await controller.delete();
    if (requestId == null || !context.mounted) return;
    Navigator.pop(context, requestId);
  }
}
