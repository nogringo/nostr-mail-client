import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/local_queue_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../utils/format_relative_time.dart';
import 'delivery_target_row.dart';
import 'stat_count.dart';

class PendingBroadcastCard extends StatelessWidget {
  const PendingBroadcastCard({
    super.key,
    required this.record,
    required this.controller,
  });

  final QueuedBroadcast record;
  final LocalQueueController controller;

  String _kindLabel(AppLocalizations l, int kind) {
    switch (kind) {
      case 0:
        return l.localQueueKindMetadata;
      case 1059:
        return l.localQueueKindGiftWrap;
      case 1985:
        return l.localQueueKindLabel;
      case 10002:
        return l.localQueueKindNip65;
      case 10050:
        return l.localQueueKindDmRelays;
      case 10063:
        return l.localQueueKindBlossomServers;
      default:
        return l.localQueueKindGeneric(kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final acked = record.ackedRelays.toSet();
    final errors = record.lastErrors;

    return Card.outlined(
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    _kindLabel(l, record.event.kind),
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
                    count: record.ackedRelays.length,
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
              final expanded = controller.expandedItemId.value == record.id;
              return IconButton(
                onPressed: () => controller.toggleExpanded(record.id),
                tooltip: expanded
                    ? l.localQueueHideDetails
                    : l.localQueueShowDetails,
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              );
            }),
          ),
          Obx(() {
            final expanded = controller.expandedItemId.value == record.id;
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
                    ...record.relays.map(
                      (r) => DeliveryTargetRow(
                        url: r,
                        status: acked.contains(r)
                            ? DeliveryTargetStatus.acked
                            : errors.containsKey(r)
                                ? DeliveryTargetStatus.failed
                                : DeliveryTargetStatus.pending,
                        errorMessage: errors[r],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            controller.rebroadcastEvent(record.id),
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
