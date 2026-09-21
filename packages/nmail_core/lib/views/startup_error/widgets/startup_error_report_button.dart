import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nmail_core/app/config/app_config.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class StartupErrorReportButton extends StatelessWidget {
  const StartupErrorReportButton({super.key, required this.details});

  final String details;

  /// Long stack traces make the URL unusable, and the copy button still hands
  /// over the whole thing.
  static const _maxDetailsLength = 1500;

  Uri get _issueUrl {
    final body = details.length > _maxDetailsLength
        ? '${details.substring(0, _maxDetailsLength)}\n...'
        : details;

    return Uri.parse('${AppConfig.sourceCodeUrl}/issues/new').replace(
      queryParameters: {
        'title': 'Nmail could not start',
        'body': '```\n$body\n```',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return TextButton.icon(
      onPressed: () => launchUrl(_issueUrl),
      icon: const Icon(Icons.open_in_new),
      label: Text(l.startupErrorReport),
    );
  }
}
