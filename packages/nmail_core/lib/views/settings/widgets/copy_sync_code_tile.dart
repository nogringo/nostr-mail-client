import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/device_auth.dart';
import 'package:nmail_core/services/sensitive_clipboard.dart';
import 'settings_action_tile.dart';

class CopySyncCodeTile extends StatelessWidget {
  CopySyncCodeTile({
    super.key,
    required this.nsec,
    required this.index,
    required this.count,
  });

  final String nsec;
  final int index;
  final int count;

  final _copied = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return ValueListenableBuilder(
      valueListenable: _copied,
      builder: (context, copied, _) => SettingsActionTile(
        icon: copied ? Icons.check : Icons.key,
        title: copied ? l.settingsSyncCodeCopied : l.settingsCopySyncCode,
        index: index,
        count: count,
        onTap: () => _copy(l),
      ),
    );
  }

  Future<void> _copy(AppLocalizations l) async {
    // macOS writes the rest of this sentence in the system language.
    final systemL = lookupAppLocalizations(
      basicLocaleListResolution(
        WidgetsBinding.instance.platformDispatcher.locales,
        AppLocalizations.supportedLocales,
      ),
    );
    final confirmed = await DeviceAuth.confirm(
      title: l.deviceAuthTitle,
      hint: l.settingsCopySyncCode,
      reason: l.settingsSyncCodeAuthReason,
      macosReason: systemL.settingsSyncCodeAuthMacosReason,
    );
    if (!confirmed) return;
    await SensitiveClipboard.copy(nsec, label: 'sync code');
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () => _copied.value = false);
  }
}
