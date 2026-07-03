import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/utils/confirm_open_link.dart';
import 'package:nmail_core/utils/html_has_images.dart';
import 'package:nmail_standard/views/email/email_controller.dart';

class HtmlBodyView extends StatelessWidget {
  final String htmlBody;

  const HtmlBodyView({super.key, required this.htmlBody});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasImages = htmlHasImages(htmlBody);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImages && !EmailController.to.showImages)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.emailImagesHidden,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    EmailController.to.showImages = true;
                    EmailController.to.update();
                  },
                  child: Text(l.emailLoadImages),
                ),
              ],
            ),
          ),
        SelectionArea(
          child: HtmlWidget(
            htmlBody,
            key: ValueKey(EmailController.to.showImages),
            customWidgetBuilder: EmailController.to.showImages
                ? null
                : (element) {
                    if (element.localName == 'img') {
                      return const SizedBox.shrink();
                    }
                    return null;
                  },
            onTapUrl: (url) {
              confirmOpenLink(url);
              return true;
            },
          ),
        ),
      ],
    );
  }
}
