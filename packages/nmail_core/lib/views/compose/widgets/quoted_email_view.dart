import 'package:flutter/material.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/views/email/widgets/html_body_view.dart';

import 'quote_actions.dart';

/// The email a reply or forward quotes, read-only below the editor.
class QuotedEmailView extends StatelessWidget {
  const QuotedEmailView({super.key, required this.controller});

  final ComposeController controller;

  @override
  Widget build(BuildContext context) {
    final emailHtml = controller.quotedEmailHtml;
    if (emailHtml == null) return const SizedBox.shrink();

    final isReply = controller.quoteIsReply;
    final expanded = !isReply || controller.quoteExpanded;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        if (isReply) QuoteActions(controller: controller, expanded: expanded),
        if (expanded)
          Padding(
            padding: const EdgeInsets.all(16),
            child: HtmlBodyView(
              emailHtml: emailHtml,
              images: controller,
              showImages: controller.showQuotedImages,
              onShowImages: controller.loadQuotedImages,
            ),
          ),
      ],
    );
  }
}
