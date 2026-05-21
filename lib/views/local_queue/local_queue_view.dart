import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/local_queue_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/responsive_helper.dart';
import '../shared/desktop_shell.dart';
import 'widgets/local_queue_empty_state.dart';
import 'widgets/pending_broadcast_card.dart';
import 'widgets/pending_upload_card.dart';
import 'widgets/stats_header.dart';

class LocalQueueView extends StatelessWidget {
  const LocalQueueView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<LocalQueueController>();
    final isWide = ResponsiveHelper.isNotMobile(context);

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(l.localQueueHeaderTitle),
        actions: [
          Obx(
            () => IconButton(
              tooltip: l.localQueueRetryAll,
              onPressed:
                  controller.isRetrying.value || !controller.hasPending
                  ? null
                  : controller.retryAll,
              icon: controller.isRetrying.value
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final broadcasts = controller.pendingBroadcasts;
          final uploads = controller.pendingUploads;

          if (broadcasts.isEmpty && uploads.isEmpty) {
            return const LocalQueueEmptyState();
          }

          return ResponsiveCenter(
            maxWidth: 720,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StatsHeader(controller: controller),
                if (broadcasts.isNotEmpty) ...[
                  _SectionHeader(label: l.localQueueSectionBroadcasts),
                  ...broadcasts.map(
                    (b) => PendingBroadcastCard(
                      record: b,
                      controller: controller,
                    ),
                  ),
                ],
                if (uploads.isNotEmpty) ...[
                  _SectionHeader(label: l.localQueueSectionUploads),
                  ...uploads.map(
                    (u) => PendingUploadCard(
                      record: u,
                      controller: controller,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );

    if (isWide) {
      return DesktopShell(body: scaffold);
    }
    return scaffold;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
