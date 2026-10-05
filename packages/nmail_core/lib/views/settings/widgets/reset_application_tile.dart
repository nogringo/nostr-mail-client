import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
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

    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ResettingDialog(),
    );
    try {
      await GetIt.I<SettingsController>().resetApplication();
    } catch (e) {
      // The tile may be gone: the reset leaves for the login screen.
      if (navigator.mounted) {
        ToastHelper.error(
          navigator.context,
          l.settingsResetApplicationFailed,
          description: e.toString(),
        );
      }
    } finally {
      if (navigator.mounted && navigator.canPop()) navigator.pop();
    }
  }
}
