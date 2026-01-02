import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void success(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.success,
      alignment: Alignment.bottomRight,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  static void error(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.error,
      alignment: Alignment.bottomRight,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  static void info(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.info,
      alignment: Alignment.bottomRight,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
