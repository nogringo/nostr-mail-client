import 'package:blossom_upload_queue_shim_for_ndk/blossom_upload_queue_shim_for_ndk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/local_queue_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/format_relative_time.dart';
import 'delivery_target_row.dart';
import 'stat_count.dart';

class PendingUploadCard extends StatelessWidget {
  const PendingUploadCard({
    super.key,
    required this.record,
    required this.controller,
  });

  final QueuedBlobUpload record;
  final LocalQueueController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final acked = record.ackedServers.toSet();
    final errors = record.lastErrors;
    final shortHash = record.sha256.length >= 12
        ? record.sha256.substring(0, 12)
        : record.sha256;

    return Card.outlined(
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    l.localQueueBlobLabel(shortHash),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatRelativeTime(
                    context,
                    DateTime.fromMillisecondsSinceEpoch(record.createdAt),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  StatCount(
                    count: record.ackedServers.length,
                    color: theme.colorScheme.tertiary,
                    label: l.localQueueStatSucceeded,
                  ),
                  const SizedBox(width: 16),
                  StatCount(
                    count: errors.length,
                    color: theme.colorScheme.error,
                    label: l.localQueueStatFailed,
                  ),
                ],
              ),
            ),
            trailing: Obx(() {
              final expanded =
                  controller.expandedItemId.value == record.sha256;
              return IconButton(
                onPressed: () => controller.toggleExpanded(record.sha256),
                tooltip: expanded
                    ? l.localQueueHideDetails
                    : l.localQueueShowDetails,
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              );
            }),
          ),
          Obx(() {
            final expanded =
                controller.expandedItemId.value == record.sha256;
            return AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    ...record.servers.map(
                      (s) => DeliveryTargetRow(
                        url: s,
                        status: acked.contains(s)
                            ? DeliveryTargetStatus.acked
                            : errors.containsKey(s)
                                ? DeliveryTargetStatus.failed
                                : DeliveryTargetStatus.pending,
                        errorMessage: errors[s],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            controller.reuploadBlob(record.sha256),
                        icon: const Icon(Icons.refresh),
                        label: Text(l.localQueueRetryItem),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
