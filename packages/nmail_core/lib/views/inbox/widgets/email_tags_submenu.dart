import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/controllers/inbox_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/controllers/tags_picker_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/mailbox.dart';
import 'package:nmail_core/views/mailboxes/widgets/show_mail_entry_form.dart';
import 'package:nmail_core/widgets/controller_builder.dart';

/// The labels of [email] as checkboxes, applied together.
class EmailTagsSubmenu extends StatelessWidget {
  final EmailSummary email;

  /// Outlives the menu, to open the new label form once it closes.
  final BuildContext actionContext;

  const EmailTagsSubmenu({
    super.key,
    required this.email,
    required this.actionContext,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final mailboxes = GetIt.I<MailboxesController>();
    return ControllerBuilder(
      create: () => TagsPickerController([email]),
      builder: (context, picker) {
        // Read now: menu items run their action once the menu has closed
        // and disposed the picker.
        final changes = picker.changes;
        return ListenableBuilder(
          listenable: mailboxes,
          builder: (context, _) => SubmenuButton(
            leadingIcon: const Icon(Icons.label_outline),
            menuChildren: [
              for (final tag in mailboxes.tags)
                CheckboxMenuButton(
                  value: picker.stateOf(tag.id),
                  closeOnActivate: false,
                  onChanged: picker.isHeldByRule(tag.id)
                      ? null
                      : (_) => picker.toggle(tag.id),
                  trailingIcon: picker.isHeldByRule(tag.id)
                      ? Text(l.mailboxAppliedByRule)
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Icon(
                        Icons.label,
                        color: MailboxesController.colorOf(
                          tag,
                          on: colorScheme.surfaceContainer,
                        ),
                      ),
                      Text(tag.name),
                    ],
                  ),
                ),
              if (mailboxes.tags.isNotEmpty) const Divider(height: 1),
              MenuItemButton(
                leadingIcon: const Icon(Icons.new_label_outlined),
                onPressed: () => _createTag(changes),
                child: Text(l.mailboxNewTag),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.check),
                onPressed: picker.hasChanges ? () => _apply(changes) : null,
                child: Text(l.mailboxApply),
              ),
            ],
            child: Text(l.mailboxTags),
          ),
        );
      },
    );
  }

  Future<void> _apply(TagChanges changes) => GetIt.I<InboxController>()
      .applyTags([email], add: changes.add, remove: changes.remove);

  /// Keeps the boxes checked so far, which the form would otherwise drop.
  Future<void> _createTag(TagChanges changes) async {
    final created = await showMailEntryForm(
      actionContext,
      kind: MailEntryKind.tag,
    );
    final add = {...changes.add, ?created?.id};
    if (add.isEmpty && changes.remove.isEmpty) return;
    await _apply((add: add, remove: changes.remove));
  }
}
