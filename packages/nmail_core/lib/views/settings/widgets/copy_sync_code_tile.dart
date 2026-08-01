import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/sensitive_clipboard.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'settings_action_tile.dart';

class CopySyncCodeTile extends StatelessWidget {
  const CopySyncCodeTile({
    super.key,
    required this.nsec,
    required this.index,
    required this.count,
  });

  final String nsec;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SettingsActionTile(
      icon: Icons.key,
      title: l.settingsCopySyncCode,
      index: index,
      count: count,
      onTap: () => _copy(context),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final l = AppLocalizations.of(context);
    await SensitiveClipboard.copy(nsec, label: 'sync code');
    // Android already shows its own copy confirmation.
    if (!PlatformHelper.isAndroid && context.mounted) {
      ToastHelper.success(context, l.settingsSyncCodeCopied);
    }
  }
}
