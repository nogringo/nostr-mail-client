import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'reset_application_dialog.dart';
import 'resetting_dialog.dart';
import 'settings_action_tile.dart';

class ResetApplicationTile extends StatelessWidget {
  const ResetApplicationTile({
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
      icon: Icons.delete_forever,
      title: l.settingsResetApplication,
      isDestructive: true,
      index: index,
      count: count,
      onTap: () => _reset(context),
    );
  }

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const ResetApplicationDialog(),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ResettingDialog(),
    );
    await Get.find<SettingsController>().resetApplication();
    if (navigator.mounted && navigator.canPop()) navigator.pop();
  }
}
