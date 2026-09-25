import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'entry_color_picker.dart';
import 'entry_name_field.dart';
import 'entry_rules_section.dart';

class MailEntryFormFields extends StatelessWidget {
  final MailEntryFormController controller;
  final VoidCallback onSubmitted;

  const MailEntryFormFields({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntryNameField(controller: controller, onSubmitted: onSubmitted),
        const SizedBox(height: 16),
        EntryColorPicker(controller: controller),
        const SizedBox(height: 24),
        EntryRulesSection(controller: controller),
      ],
    );
  }
}
