import 'package:flutter/material.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/format_date_time.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';

/// The span of mail already read from one relay.
class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({
    super.key,
    required this.status,
    required this.index,
    required this.count,
  });

  final EmailSyncStatus status;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final oldest = formatSyncTimestamp(context, status.oldestTimestamp);
    final newest = formatSyncTimestamp(context, status.newestTimestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListTile(
        tileColor: colorScheme.surfaceContainerHigh,
        shape: segmentedListShape(index: index, count: count),
        minTileHeight: 72,
        leading: const Icon(Icons.dns_outlined),
        title: Text(
          formatRelayUrl(status.relayUrl),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('$oldest → $newest'),
      ),
    );
  }
}
