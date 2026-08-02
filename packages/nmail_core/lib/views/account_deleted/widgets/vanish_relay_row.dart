import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// One relay of a request to vanish, and how it answered.
class VanishRelayRow extends StatelessWidget {
  const VanishRelayRow({
    super.key,
    required this.url,
    required this.isErased,
    required this.isNotErased,
    required this.index,
    required this.count,
  });

  final String url;
  final bool isErased;
  final bool isNotErased;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (String status, Color color) = switch ((isErased, isNotErased)) {
      (true, _) => (l.accountDeletedRelayErased, colorScheme.primary),
      (_, true) => (l.accountDeletedRelayNotErased, colorScheme.error),
      _ => (l.accountDeletedRelayPending, colorScheme.onSurfaceVariant),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 56,
        title: Text(formatRelayUrl(url), overflow: TextOverflow.ellipsis),
        trailing: Text(
          status,
          style: theme.textTheme.labelMedium?.copyWith(color: color),
        ),
      ),
    );
  }
}
