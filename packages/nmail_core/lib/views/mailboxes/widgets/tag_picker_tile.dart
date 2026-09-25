import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/controllers/tags_picker_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class TagPickerTile extends StatelessWidget {
  final TagsPickerController controller;
  final MailEntry tag;

  const TagPickerTile({super.key, required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final heldByRule = controller.isHeldByRule(tag.id);
    return Obx(
      () => CheckboxListTile(
        tristate: true,
        value: controller.stateOf(tag.id),
        onChanged: heldByRule ? null : (_) => controller.toggle(tag.id),
        controlAffinity: ListTileControlAffinity.leading,
        secondary: Icon(Icons.label, color: MailboxesController.colorOf(tag)),
        title: Text(tag.name),
        subtitle: heldByRule ? Text(l.mailboxAppliedByRule) : null,
      ),
    );
  }
}
