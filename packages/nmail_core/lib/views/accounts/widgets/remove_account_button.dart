import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'remove_account_dialog.dart';

class RemoveAccountButton extends StatelessWidget {
  const RemoveAccountButton({super.key, required this.pubkey});

  final String pubkey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final auth = Get.find<AuthController>();

    return Obx(() {
      final pending = auth.pendingAccountPubkey.value;
      if (pending == pubkey) {
        return const SizedBox.square(
          dimension: 48,
          child: Center(
            child: SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      return IconButton(
        icon: const Icon(Icons.close, size: 20),
        tooltip: l.accountsRemove,
        onPressed: pending != null ? null : () => _confirmRemove(context),
      );
    });
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => RemoveAccountDialog(pubkey: pubkey),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await Get.find<AuthController>().removeAccount(pubkey);
    } catch (_) {
      if (context.mounted) ToastHelper.error(context, l.accountsRemoveFailed);
    }
  }
}
