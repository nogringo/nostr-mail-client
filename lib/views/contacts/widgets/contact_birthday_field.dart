import 'package:flutter/material.dart';

import '../../../utils/contact_birthday_utils.dart';

class ContactBirthdayField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;

  const ContactBirthdayField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
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
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final value = controller.text.trim();
            final displayValue = value.isEmpty
                ? hintText
                : formatContactBirthdayForDisplay(context, value);
            final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: value.isEmpty
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                  : colorScheme.onSurface,
            );
            return InkWell(
              borderRadius: radius,
              onTap: () => _selectDate(context),
              child: InputDecorator(
                isEmpty: value.isEmpty,
                decoration: InputDecoration(
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
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.4,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    tooltip: label,
                    onPressed: () => _selectDate(context),
                  ),
                ),
                child: Text(
                  displayValue,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = parseContactBirthday(controller.text) ?? DateTime(1990);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    controller.text = formatContactBirthdayValue(selected);
  }
}
