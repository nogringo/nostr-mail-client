import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void success(
    BuildContext context,
    String message, {
    String? description,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      title: Text(message),
      description: description != null ? Text(description) : null,
      type: ToastificationType.success,
      alignment: Alignment.bottomRight,
      autoCloseDuration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? description,
    Duration duration = const Duration(seconds: 10),
  }) {
    toastification.show(
      context: context,
      title: Text(message),
      description: description != null ? Text(description) : null,
      type: ToastificationType.error,
      alignment: Alignment.bottomRight,
      autoCloseDuration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    String? description,
    Duration duration = const Duration(seconds: 5),
  }) {
    toastification.show(
      context: context,
      title: Text(message),
      description: description != null ? Text(description) : null,
      type: ToastificationType.info,
      alignment: Alignment.bottomRight,
      autoCloseDuration: duration,
    );
  }
}
