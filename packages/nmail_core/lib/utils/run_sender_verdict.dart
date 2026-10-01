import 'package:flutter/widgets.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// Runs [apply] and reports a failure as a toast, an account that cannot sign
/// being one. Completes with whether the verdict went through.
Future<bool> runSenderVerdict(
  BuildContext context,
  Future<void> Function() apply,
) async {
  final l = AppLocalizations.of(context);
  try {
    await apply();
    return true;
  } catch (e) {
    if (context.mounted) {
      ToastHelper.error(
        context,
        l.senderVerdictFailed,
        description: e.toString(),
      );
    }
    return false;
  }
}
