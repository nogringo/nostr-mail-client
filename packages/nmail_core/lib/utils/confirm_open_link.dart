// TODO: Add option to trust domain and skip confirmation for trusted domains (maybe at nostr level)
// TODO: Show warning when link text differs from actual URL (phishing detection)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> confirmOpenLink(BuildContext context, String url) async {
  final l = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l.linkOpenTitle),
      content: SelectableText(
        url,
        style: TextStyle(color: Theme.of(dialogContext).colorScheme.primary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.pop(dialogContext, false);
            ToastHelper.success(context, l.linkCopied);
          },
          child: Text(l.actionCopy),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l.actionOpen),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
