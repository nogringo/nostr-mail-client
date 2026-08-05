import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'delete_account_dialog.dart';
import 'settings_action_tile.dart';

class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({
    super.key,
    required this.index,
    required this.count,
  });

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SettingsActionTile(
      icon: Icons.person_off_outlined,
      title: l.settingsDeleteAccount,
      isDestructive: true,
      index: index,
      count: count,
      onTap: () => _delete(context),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final pubkey = Get.find<AuthController>().publicKey;
    if (pubkey == null) return;

    final requestId = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteAccountDialog(pubkey: pubkey),
    );
    if (requestId == null) return;

    // The account is already gone and this route with it, so navigate through
    // the router rather than a context the wipe has just torn down.
    AppRouter.router.go(AppRoutes.accountDeletedPath(requestId));
  }
}
