import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/views/email/widgets/person_anchor.dart';
import '../../../widgets/email_avatar.dart';
import '../../../widgets/nostr_avatar.dart';
import 'recipient_chip_actions.dart';

class RecipientChip extends StatelessWidget {
  final RecipientField field;
  final Recipient recipient;
  final VoidCallback onDelete;

  const RecipientChip({
    super.key,
    required this.field,
    required this.recipient,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (recipient.isLoading) {
      return const Chip(
        shape: StadiumBorder(),
        label: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return PersonAnchor(
      person: recipientPerson(recipient),
      actions: (actionContext, contact) => buildRecipientChipActions(
        actionContext,
        contact,
        field: field,
        recipient: recipient,
      ),
      builder: (context, open) => recipient.isNostr
          ? _buildNostrChip(context, open)
          : _buildLegacyChip(context, open),
    );
  }

  Widget _buildNostrChip(BuildContext context, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputChip(
      onPressed: onPressed,
      shape: const StadiumBorder(),
      backgroundColor: colorScheme.primaryContainer,
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      avatar: _buildAvatar(context),
      label: Obx(() {
        final pubkey = recipient.pubkey;
        final metadata = pubkey == null
            ? null
            : Get.find<MetadataService>().of(pubkey).value;
        return Text(
          metadata?.realName ?? recipient.label,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        );
      }),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: colorScheme.primary.withValues(alpha: 0.6),
      ),
      onDeleted: onDelete,
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final pubkey = recipient.pubkey;
    if (pubkey == null) {
      return EmailAvatar(
        mailAddress:
            recipient.mailAddress ?? MailAddress(null, recipient.input),
        radius: 12,
      );
    }

    return NostrAvatar(pubkey: pubkey, radius: 12);
  }

  Widget _buildLegacyChip(BuildContext context, VoidCallback onPressed) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputChip(
      onPressed: onPressed,
      shape: const StadiumBorder(),
      backgroundColor: colorScheme.surfaceContainerHighest,
      side: BorderSide(color: colorScheme.outlineVariant),
      label: Text(
        recipient.label,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      onDeleted: onDelete,
    );
  }
}
