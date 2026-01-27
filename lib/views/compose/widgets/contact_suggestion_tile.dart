import 'package:flutter/material.dart';

import '../../../models/contact.dart';

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
                    const SizedBox(height: 2),
                    Text(
                      contact.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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
    final colorScheme = Theme.of(context).colorScheme;

    if (contact.picture != null && contact.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: NetworkImage(contact.picture!),
      );
    }

    final initial = contact.displayName?.isNotEmpty == true
        ? contact.displayName![0].toUpperCase()
        : contact.legacyEmail?.isNotEmpty == true
        ? contact.legacyEmail![0].toUpperCase()
        : contact.pubkey?.isNotEmpty == true
        ? contact.pubkey![0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 18,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSourceIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final IconData icon;
    final String tooltip;

    switch (contact.source) {
      case ContactSource.emailHistory:
        icon = Icons.history;
        tooltip = 'Email history';
      case ContactSource.nostrFollow:
        icon = Icons.person;
        tooltip = 'Following';
      case ContactSource.cachedProfile:
        icon = Icons.cached;
        tooltip = 'Cached profile';
      case ContactSource.nip05Lookup:
        icon = Icons.verified;
        tooltip = 'NIP-05 verified';
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
