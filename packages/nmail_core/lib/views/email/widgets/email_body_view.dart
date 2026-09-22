import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/views/email/widgets/html_body_view.dart';

import 'attachments_section_view.dart';

class EmailBodyView extends StatelessWidget {
  final Email email;

  const EmailBodyView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final emailHtml = EmailController.to.emailHtml;
    final attachments = email.attachmentRefs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attachments section
        if (attachments.isNotEmpty) ...[
          AttachmentsSectionView(attachments: attachments, email: email),
          const Divider(height: 32),
        ],
        // Email body
        if (emailHtml != null)
          HtmlBodyView(emailHtml: emailHtml)
        else
          SelectableText(
            email.body,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
      ],
    );
  }
}
