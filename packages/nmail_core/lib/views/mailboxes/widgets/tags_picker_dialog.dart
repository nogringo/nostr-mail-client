import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/controllers/tags_picker_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'show_mail_entry_form.dart';
import 'tag_picker_tile.dart';

/// Pops with the [TagChanges] to apply.
class TagsPickerDialog extends StatelessWidget {
  final TagsPickerController controller;

  const TagsPickerDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mailboxes = Get.find<MailboxesController>();
    return AlertDialog(
      title: Text(l.mailboxTags),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: SizedBox(
        width: 360,
        child: Obx(
          () => ListView(
            shrinkWrap: true,
            children: [
              if (mailboxes.tags.isEmpty)
                ListTile(title: Text(l.mailboxNoTags)),
              for (final tag in mailboxes.tags)
                TagPickerTile(
                  key: ValueKey(tag.id),
                  controller: controller,
                  tag: tag,
                ),
              ListTile(
                leading: const Icon(Icons.new_label_outlined),
                title: Text(l.mailboxNewTag),
                onTap: () => _createTag(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        Obx(
          () => FilledButton(
            onPressed: controller.hasChanges
                ? () => Navigator.pop(context, controller.changes)
                : null,
            child: Text(l.mailboxApply),
          ),
        ),
      ],
    );
  }

  Future<void> _createTag(BuildContext context) async {
    final created = await showMailEntryForm(context, kind: MailEntryKind.tag);
    if (created != null) controller.check(created.id);
  }
}
