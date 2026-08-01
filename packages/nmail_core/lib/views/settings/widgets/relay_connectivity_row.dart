import 'package:flutter/material.dart';

import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';

/// One live relay connection, listed inside [RelayConnectivityTile].
class RelayConnectivityRow extends StatelessWidget {
  const RelayConnectivityRow({
    super.key,
    required this.url,
    required this.isConnected,
  });

  final String url;
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      title: Text(formatRelayUrl(url), overflow: TextOverflow.ellipsis),
      trailing: Text(
        isConnected ? l.connectivityConnected : l.connectivityDisconnected,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isConnected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
