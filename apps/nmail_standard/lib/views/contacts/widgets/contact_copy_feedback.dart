import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../utils/platform_helper.dart';

void showContactCopyFeedback(BuildContext context, String message) {
  if (PlatformHelper.isAndroid) return;

  final colorScheme = Theme.of(context).colorScheme;
  toastification.show(
    context: context,
    alignment: Alignment.bottomCenter,
    title: Text(message),
    style: ToastificationStyle.simple,
    backgroundColor: colorScheme.primary,
    foregroundColor: colorScheme.onPrimary,
    borderRadius: BorderRadius.circular(999),
    borderSide: BorderSide.none,
    closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    closeOnClick: true,
    autoCloseDuration: const Duration(milliseconds: 1400),
  );
}
