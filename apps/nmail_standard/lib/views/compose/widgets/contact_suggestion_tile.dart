import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/contact.dart';
import '../../../widgets/email_avatar.dart';
import '../../../widgets/nostr_avatar.dart';

class ContactSuggestionTile extends StatelessWidget {
  final Contact contact;
  final bool isHighlighted;
  final VoidCallback onTap;

  const ContactSuggestionTile({
    super.key,
    required this.contact,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isHighlighted
          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        canRequestFocus: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildAvatar(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contact.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildSourceIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final pubkey = contact.pubkey;
    if (pubkey == null) {
      return EmailAvatar(
        mailAddress: contact.mailAddress ?? MailAddress(null, contact.label),
        radius: 18,
      );
    }

    return NostrAvatar(pubkey: pubkey, radius: 18);
  }

  Widget _buildSourceIndicator(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final IconData icon;
    final String tooltip;

    switch (contact.source) {
      case ContactSource.addressBook:
        icon = Icons.contacts;
        tooltip = l.contactSourceAddressBook;
      case ContactSource.emailHistory:
        icon = Icons.history;
        tooltip = l.contactSourceEmailHistory;
      case ContactSource.nostrFollow:
        icon = Icons.person;
        tooltip = l.contactSourceFollowing;
      case ContactSource.cachedProfile:
        icon = Icons.cached;
        tooltip = l.contactSourceCachedProfile;
      case ContactSource.nip05Lookup:
        icon = Icons.verified;
        tooltip = l.contactSourceNip05Verified;
    }

    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: 16,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
