import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/create_identity_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/nostr_avatar.dart';
import 'duplicate_identity_error.dart';

class PreviewSection extends StatelessWidget {
  final CreateIdentityController controller;

  const PreviewSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GetBuilder<CreateIdentityController>(
      builder: (_) {
        final mailAddress = controller.buildIdentity();

        if (!controller.hasRequiredFields || mailAddress == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.createIdentityPreview,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l.createIdentityPreviewEmpty,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.createIdentityPreview,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildVisualPreview(context, mailAddress),
            _buildRawPreview(context, mailAddress),
            if (controller.hasExactDuplicate) ...[
              const SizedBox(height: 12),
              const DuplicateIdentityError(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRawPreview(BuildContext context, MailAddress address) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        address.encode(),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildVisualPreview(BuildContext context, MailAddress address) {
    final hasDisplayName =
        address.personalName != null && address.personalName!.isNotEmpty;

    return ListTile(
      contentPadding: .zero,
      leading: NostrAvatar(pubkey: controller.myHex),
      title: Text(
        hasDisplayName ? address.personalName! : address.email,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: hasDisplayName ? Text(address.email) : null,
    );
  }
}
