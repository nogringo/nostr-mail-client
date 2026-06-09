import 'dart:async';

import 'package:flutter/material.dart';

class ContactMethodsField extends StatelessWidget {
  final String label;
  final String hintText;
  final List<String> values;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String addTooltip;
  final String Function(String value)? displayLabel;
  final Widget Function(String value)? labelBuilder;
  final Widget? Function(String value)? avatarBuilder;
  final FutureOr<void> Function() onAdd;
  final ValueChanged<String> onRemove;

  const ContactMethodsField({
    super.key,
    required this.label,
    required this.hintText,
    required this.values,
    required this.controller,
    required this.addTooltip,
    required this.onAdd,
    required this.onRemove,
    this.keyboardType,
    this.displayLabel,
    this.labelBuilder,
    this.avatarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(8);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: colorScheme.outlineVariant.withValues(alpha: 0.35),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (values.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final value in values)
                InputChip(
                  shape: const StadiumBorder(),
                  avatar: avatarBuilder?.call(value),
                  label:
                      labelBuilder?.call(value) ??
                      Text(displayLabel?.call(value) ?? value),
                  onDeleted: () => onRemove(value),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            if (value.endsWith(' ') ||
                value.endsWith(',') ||
                value.endsWith(';')) {
              onAdd();
            }
          },
          onSubmitted: (_) {
            onAdd();
          },
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              tooltip: addTooltip,
              onPressed: () {
                onAdd();
              },
            ),
          ),
        ),
      ],
    );
  }
}
