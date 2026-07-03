// TODO: Add option to trust domain and skip confirmation for trusted domains (maybe at nostr level)
// TODO: Show warning when link text differs from actual URL (phishing detection)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_standard/utils/toast_helper.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> confirmOpenLink(String url) async {
  final l = AppLocalizations.of(Get.context!);
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text(l.linkOpenTitle),
      content: SelectableText(
        url,
        style: TextStyle(color: Theme.of(Get.context!).colorScheme.primary),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(l.actionCancel),
        ),
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Get.back(result: false);
            ToastHelper.success(Get.context!, l.linkCopied);
          },
          child: Text(l.actionCopy),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text(l.actionOpen),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}
