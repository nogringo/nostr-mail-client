import 'package:flutter/material.dart';

/// Shared "quiet" input decoration used by the contact form fields: a filled,
/// rounded box with a soft outline that turns primary on focus.
InputDecoration quietInputDecoration(
  BuildContext context, {
  String? hintText,
  Widget? suffixIcon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
    ),
  );
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    ),
    suffixIcon: suffixIcon,
  );
}
