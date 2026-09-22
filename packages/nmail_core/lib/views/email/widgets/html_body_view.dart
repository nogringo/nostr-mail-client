import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/confirm_open_link.dart';
import 'package:nmail_core/utils/prepare_email_html.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/views/email/widgets/email_html_surface.dart';

class HtmlBodyView extends StatelessWidget {
  final EmailHtml emailHtml;

  const HtmlBodyView({super.key, required this.emailHtml});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (emailHtml.hasImages && !EmailController.to.showImages)
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
        EmailHtmlSurface(
          emailHtml: emailHtml,
          child: SelectionArea(
            child: HtmlWidget(
              emailHtml.html,
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
                confirmOpenLink(context, url);
                return true;
              },
            ),
          ),
        ),
      ],
    );
  }
}
