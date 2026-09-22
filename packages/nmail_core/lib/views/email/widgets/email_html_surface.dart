import 'package:flutter/material.dart';

import 'package:nmail_core/utils/app_color_schemes.dart';
import 'package:nmail_core/utils/prepare_email_html.dart';

/// Reads an email that brings its own colors on a light surface.
///
/// Senders design against a white background, so their text colors turn
/// unreadable under the dark theme. An email that declares no color of its
/// own, or that paints its own page background, keeps the app theme instead:
/// forcing a light surface under an email designed for dark would leave its
/// pale text unreadable.
class EmailHtmlSurface extends StatelessWidget {
  final EmailHtml emailHtml;
  final Widget child;

  const EmailHtmlSurface({
    super.key,
    required this.emailHtml,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!emailHtml.declaresColors ||
        emailHtml.paintsOwnBackground ||
        Theme.of(context).brightness == Brightness.light) {
      return child;
    }

    // HtmlWidget takes link and default text colors from the ambient theme,
    // so the whole subtree has to switch, not just the background.
    final theme = ThemeData.from(colorScheme: appLightColorScheme());
    return Theme(
      data: theme,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colorScheme.onSurface),
          child: child,
        ),
      ),
    );
  }
}
