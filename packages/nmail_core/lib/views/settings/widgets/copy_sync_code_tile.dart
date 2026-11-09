import 'package:flutter/material.dart';

import 'package:nmail_core/app/routes/app_router.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/device_auth.dart';
import 'package:nmail_core/services/sensitive_clipboard.dart';
import 'package:nmail_core/utils/system_app_localizations.dart';
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
    final systemL = systemAppLocalizations();
    final confirmed = await DeviceAuth.confirm(
      title: l.deviceAuthTitle,
      hint: l.settingsCopySyncCode,
      reason: l.settingsSyncCodeAuthReason,
      macosReason: systemL.settingsSyncCodeAuthMacosReason,
    );
    if (!confirmed) return;
    if (!DeviceAuth.isSupported) {
      // The device could not verify anything: on web the whole process is
      // one XSS away from this key, elsewhere there is no lock to check.
      // Say so plainly instead of silently copying.
      final ctx = AppRouter.rootContext;
      if (ctx == null || !ctx.mounted) return;
      final proceed = await showDialog<bool>(
        context: ctx,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No screen lock on this device'),
          content: const Text(
            // TODO(l10n): localize alongside the other sync-code strings.
            'This device cannot verify it is you. Anyone who can open this '
            'app or this page can copy the key. Copy it anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Copy anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }
    await SensitiveClipboard.copy(nsec, label: 'sync code');
    _copied.value = true;
    Future.delayed(const Duration(seconds: 2), () => _copied.value = false);
  }
}
