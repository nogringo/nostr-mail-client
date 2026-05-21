import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/local_queue_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'stat_card.dart';

class StatsHeader extends StatelessWidget {
  const StatsHeader({super.key, required this.controller});

  final LocalQueueController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.inventory_2_outlined,
              label: l.localQueueStatItems,
              count: controller.totalCount,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.cloud_done_outlined,
              label: l.localQueueStatSucceeded,
              count: controller.totalSucceeded,
              accentColor: colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.cloud_off_outlined,
              label: l.localQueueStatFailed,
              count: controller.totalFailed,
              accentColor: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
