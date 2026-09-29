import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:pasteboard/pasteboard.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';

Future<void> copyImage(BuildContext context, Uint8List imageData) async {
  try {
    await Pasteboard.writeImage(imageData);
  } catch (_) {
    if (!context.mounted) return;
    ToastHelper.error(
      context,
      AppLocalizations.of(context).emailCopyImageFailed,
    );
  }
}
