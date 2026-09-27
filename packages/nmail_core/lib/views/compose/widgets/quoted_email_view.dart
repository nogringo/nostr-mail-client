import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/views/email/widgets/html_body_view.dart';

import 'quote_actions.dart';

/// The email a reply or forward quotes, read-only below the editor.
class QuotedEmailView extends StatelessWidget {
  const QuotedEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ComposeController.to;

    return Obx(() {
      final emailHtml = controller.quotedEmailHtml.value;
      if (emailHtml == null) return const SizedBox.shrink();

      final isReply = controller.quoteIsReply;
      final expanded = !isReply || controller.quoteExpanded.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          if (isReply) QuoteActions(expanded: expanded),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: HtmlBodyView(
                emailHtml: emailHtml,
                images: controller,
                showImages: controller.showQuotedImages.value,
                onShowImages: controller.loadQuotedImages,
              ),
            ),
        ],
      );
    });
  }
}
