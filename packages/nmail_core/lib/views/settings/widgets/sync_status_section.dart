import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/sync_status_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/format_date_time.dart';
import 'package:nmail_core/utils/relay_utils.dart';

class SyncStatusSection extends StatelessWidget {
  const SyncStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<SyncStatusController>(
      init: SyncStatusController(),
      global: false,
      builder: (controller) {
        if (controller.isLoading) {
          return ListTile(
            leading: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text(l.stateLoadingEllipsis),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              dense: true,
              title: Text(
                l.syncStatusSectionTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (controller.syncStatus == null || controller.syncStatus!.isEmpty)
              ListTile(
                leading: const Icon(Icons.sync_disabled),
                title: Text(l.syncStatusEmpty),
                subtitle: Text(l.syncStatusEmptyHint),
              )
            else
              ...controller.syncStatus!.map(
                (status) => ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: Text(
                    formatRelayUrl(status.relayUrl),
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    '${formatSyncTimestamp(context, status.oldestTimestamp)} → ${formatSyncTimestamp(context, status.newestTimestamp)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            // TODO: add description explaining when to use Resync
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.isSyncing ? null : controller.resync,
                  child: controller.isSyncing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.syncStatusResync),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
