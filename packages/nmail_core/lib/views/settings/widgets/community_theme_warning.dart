import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';

/// The NIP-36 content warning of a theme whose background image is hidden.
class CommunityThemeWarning extends StatelessWidget {
  const CommunityThemeWarning({
    super.key,
    required this.reason,
    required this.onShow,
  });

  /// Empty when the author gave none.
  final String reason;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reason.isEmpty ? l.communityThemesSensitive : reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton.icon(
                onPressed: onShow,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l.communityThemesShow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
