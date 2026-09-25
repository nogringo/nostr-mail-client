import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/showcased_nostr_app.dart';

class NostrAppTile extends StatelessWidget {
  const NostrAppTile({super.key, required this.app});

  static const width = 112.0;
  static const _iconSize = 56.0;

  final ShowcasedNostrApp app;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_iconSize / 4),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              app.assetPath,
              package: ShowcasedNostrApp.packageName,
              width: _iconSize,
              height: _iconSize,
              excludeFromSemantics: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            app.name,
            style: theme.textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            app.usage(l),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
