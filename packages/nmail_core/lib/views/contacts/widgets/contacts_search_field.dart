import 'package:flutter/material.dart';

class ContactsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const ContactsSearchField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(8);
    final baseBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
      ),
    );

    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          Icons.search,
          size: 19,
          color: colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.3),
        ),
      ),
    );
  }
}
