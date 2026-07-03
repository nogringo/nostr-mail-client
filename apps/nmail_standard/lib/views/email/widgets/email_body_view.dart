import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_standard/views/email/widgets/html_body_view.dart';

import 'attachments_section_view.dart';

class EmailBodyView extends StatelessWidget {
  final Email email;

  const EmailBodyView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final htmlBody = email.htmlBody;
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
        if (htmlBody != null && htmlBody.isNotEmpty)
          HtmlBodyView(htmlBody: htmlBody)
        else
          SelectableText(
            email.body,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
      ],
    );
  }
}
