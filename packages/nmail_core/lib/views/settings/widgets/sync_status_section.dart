import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/sync_status_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'hosting_empty_tile.dart';
import 'hosting_loading_tile.dart';
import 'resync_tile.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';
import 'sync_status_tile.dart';

class SyncStatusSection extends StatelessWidget {
  const SyncStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<SyncStatusController>(
      init: SyncStatusController(),
      global: false,
      builder: (controller) {
        final statuses = controller.syncStatus ?? const <EmailSyncStatus>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(title: l.syncStatusSectionTitle),
            if (controller.isLoading)
              const HostingLoadingTile()
            else
              SettingsGroup(
                rows: [
                  if (statuses.isEmpty)
                    (index, count) => HostingEmptyTile(
                      icon: Icons.sync_disabled,
                      message: l.syncStatusEmpty,
                      index: index,
                      count: count,
                    )
                  else
                    for (final status in statuses)
                      (index, count) => SyncStatusTile(
                        status: status,
                        index: index,
                        count: count,
                      ),
                  (index, count) => ResyncTile(
                    isSyncing: controller.isSyncing,
                    onResync: controller.resync,
                    index: index,
                    count: count,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
