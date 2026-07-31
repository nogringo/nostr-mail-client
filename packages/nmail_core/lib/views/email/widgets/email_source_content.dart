import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../email_controller.dart';

class EmailSourceContent extends StatelessWidget {
  const EmailSourceContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final monospace = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      height: 1.4,
    );

    return GetBuilder<EmailController>(
      builder: (controller) {
        if (controller.isLoadingRawContent) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final source = controller.rawContent;
        if (source == null || controller.email == null) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text(l.emailRawContentUnavailable)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                l.emailSenderNpub(
                  Nip19.encodePubKey(controller.email!.senderPubkey),
                ),
                style: monospace?.copyWith(color: theme.colorScheme.primary),
              ),
              const Divider(height: 24),
              SelectableText(source, style: monospace),
            ],
          ),
        );
      },
    );
  }
}
