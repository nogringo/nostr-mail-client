import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'delivery_url_row.dart';
import 'person_name.dart';

/// One recipient of a sent email: where it stands, then each relay that holds
/// the email for it and each server that holds its blob.
class RecipientDeliverySection extends StatelessWidget {
  const RecipientDeliverySection({
    super.key,
    required this.recipient,
    this.isSelfCopy = false,
  });

  final RecipientDelivery recipient;
  final bool isSelfCopy;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameStyle = theme.textTheme.titleMedium;

    final (String status, Color color) = switch (recipient.status) {
      DeliveryStatus.delivered => (
        recipient.isBridge
            ? l.emailDeliveryHandedToBridge
            : l.emailDeliveryDelivered,
        colorScheme.primary,
      ),
      DeliveryStatus.pending => (
        l.emailDeliverySending,
        colorScheme.onSurfaceVariant,
      ),
      DeliveryStatus.failed => (l.emailDeliveryNotDelivered, colorScheme.error),
    };
    final blob = recipient.blob;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: isSelfCopy
                    ? Text(l.emailDeliverySelfCopy, style: nameStyle)
                    : recipient.isBridge
                    ? Text(recipient.smtpAddresses.join(', '), style: nameStyle)
                    : PersonName(
                        person: EmailPerson.nostr(recipient.pubkey),
                        style: nameStyle,
                      ),
              ),
              const SizedBox(width: 16),
              Text(
                status,
                style: theme.textTheme.labelLarge?.copyWith(color: color),
              ),
            ],
          ),
        ),
        for (final (index, relay) in recipient.relays.indexed)
          DeliveryUrlRow(
            label: formatRelayUrl(relay.url),
            delivery: relay,
            index: index,
            count: recipient.relays.length,
          ),
        if (blob != null && blob.servers.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              l.emailDeliveryBlob,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final (index, server) in blob.servers.indexed)
            DeliveryUrlRow(
              label: server.url.replaceFirst(RegExp(r'^https?://'), ''),
              delivery: server,
              index: index,
              count: blob.servers.length,
            ),
        ],
      ],
    );
  }
}
