import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// Any, with or without attachments: a null condition does not constrain.
class EntryAttachmentFilter extends StatelessWidget {
  final MailEntryFormController controller;

  const EntryAttachmentFilter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          l.mailboxRuleAttachment,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Obx(
          () => SegmentedButton<bool?>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: null,
                label: Text(l.mailboxRuleAnyAttachment),
              ),
              ButtonSegment(
                value: true,
                label: Text(l.mailboxRuleWithAttachment),
              ),
              ButtonSegment(
                value: false,
                label: Text(l.mailboxRuleWithoutAttachment),
              ),
            ],
            selected: {controller.hasAttachment.value},
            onSelectionChanged: (selection) =>
                controller.hasAttachment.value = selection.single,
          ),
        ),
      ],
    );
  }
}
