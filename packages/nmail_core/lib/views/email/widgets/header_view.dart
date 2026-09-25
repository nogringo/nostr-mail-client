import 'package:flutter/material.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/widgets/tag_chips.dart';

import 'person_anchor.dart';
import 'recipients_list_view.dart';
import 'sender_row_view.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = EmailController.to;
    final email = controller.email;
    if (email == null) return const SizedBox.shrink();
    final summary = controller.summary;
    final tagIds = summary?.tags ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SelectableText(
            (email.subject?.isEmpty ?? true)
                ? l.emailNoSubject
                : email.subject!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        if (tagIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TagChips(
              tagIds: tagIds,
              // A tag its match condition holds has no label to take off.
              canRemove: (id) => summary!.labels.contains('tag:$id'),
              onRemove: controller.removeTag,
            ),
          ),
        const SizedBox(height: 8),
        PersonAnchor(
          person: controller.senderPerson,
          builder: (context, open) => Semantics(
            button: true,
            child: InkWell(
              onTap: open,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SenderRowView(),
              ),
            ),
          ),
        ),
        if (controller.showRecipients) ...[
          const SizedBox(height: 4),
          const RecipientsListView(),
        ],
      ],
    );
  }
}
