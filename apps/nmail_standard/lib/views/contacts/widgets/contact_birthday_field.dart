import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/contact_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'quiet_input_decoration.dart';

/// Birthday input: collapsed behind a single button until the user adds one,
/// then a day + month selector with an optional year. The fields sit on one
/// row when there is room and wrap to two rows on narrow (mobile) layouts.
class ContactBirthdayField extends StatelessWidget {
  final ContactFormController controller;

  const ContactBirthdayField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthFormat = DateFormat.MMMM(locale);

    return Obx(() {
      if (!controller.birthdayExpanded.value) {
        return Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: controller.expandBirthday,
            icon: const Icon(Icons.cake_outlined, size: 18),
            label: Text(l.contactsBirthdayAdd),
          ),
        );
      }

      final month = controller.birthdayMonth.value;
      final day = controller.birthdayDay.value;
      final maxDay = _daysInMonth(month);
      final hintStyle = TextStyle(color: colorScheme.onSurfaceVariant);

      final dayField = DropdownButtonFormField<int>(
        initialValue: day,
        isExpanded: true,
        borderRadius: BorderRadius.circular(8),
        decoration: quietInputDecoration(context),
        hint: Text(l.contactsBirthdayDayLabel, style: hintStyle),
        items: [
          for (var d = 1; d <= maxDay; d++)
            DropdownMenuItem(value: d, child: Text('$d')),
        ],
        onChanged: (value) => controller.birthdayDay.value = value,
      );

      final monthField = DropdownButtonFormField<int>(
        initialValue: month,
        isExpanded: true,
        borderRadius: BorderRadius.circular(8),
        decoration: quietInputDecoration(context),
        hint: Text(l.contactsBirthdayMonthLabel, style: hintStyle),
        items: [
          for (var m = 1; m <= 12; m++)
            DropdownMenuItem(
              value: m,
              child: Text(
                _capitalize(monthFormat.format(DateTime(2000, m))),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (value) {
          controller.birthdayMonth.value = value;
          // Drop an out-of-range day (e.g. Feb 30) when the month changes.
          final selectedDay = controller.birthdayDay.value;
          if (selectedDay != null && selectedDay > _daysInMonth(value)) {
            controller.birthdayDay.value = null;
          }
        },
      );

      final yearField = TextField(
        controller: controller.birthdayYearController,
        keyboardType: TextInputType.number,
        maxLength: 4,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: quietInputDecoration(
          context,
          hintText: l.contactsBirthdayYearLabel,
        ).copyWith(counterText: ''),
      );

      final clearButton = IconButton(
        icon: const Icon(Icons.close),
        tooltip: l.actionClear,
        onPressed: controller.clearBirthday,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(
              l.contactsBirthdayLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              // Three inputs plus a button need room; stack on narrow layouts.
              if (constraints.maxWidth < 380) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: dayField),
                        const SizedBox(width: 8),
                        Expanded(flex: 3, child: monthField),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: yearField),
                        const SizedBox(width: 8),
                        clearButton,
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: dayField),
                  const SizedBox(width: 8),
                  Expanded(flex: 3, child: monthField),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: yearField),
                  const SizedBox(width: 8),
                  clearButton,
                ],
              );
            },
          ),
        ],
      );
    });
  }

  static int _daysInMonth(int? month) {
    if (month == null) return 31;
    const lengths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return lengths[month - 1];
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
