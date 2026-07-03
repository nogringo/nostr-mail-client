import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';

import '../../../models/recipient.dart';
import '../../../widgets/email_avatar.dart';
import '../../../widgets/nostr_avatar.dart';

class RecipientChip extends StatelessWidget {
  final Recipient recipient;
  final VoidCallback onDelete;

  const RecipientChip({
    super.key,
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

    if (recipient.isNostr) {
      return _buildNostrChip(context);
    }

    return _buildLegacyChip(context);
  }

  Widget _buildNostrChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      shape: const StadiumBorder(),
      backgroundColor: colorScheme.primaryContainer,
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
      avatar: _buildAvatar(context),
      label: Text(
        recipient.label,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
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

  Widget _buildLegacyChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
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
