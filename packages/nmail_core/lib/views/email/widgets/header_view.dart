import 'package:flutter/material.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/views/email/email_controller.dart';

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
