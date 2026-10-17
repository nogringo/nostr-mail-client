import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

class BunkerApprovalPrompt extends StatelessWidget {
  const BunkerApprovalPrompt({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Text(l.authBunkerApprovalRequired)),
        TextButton.icon(
          onPressed: () =>
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_new),
          label: Text(l.authBunkerOpenApproval),
        ),
      ],
    );
  }
}
