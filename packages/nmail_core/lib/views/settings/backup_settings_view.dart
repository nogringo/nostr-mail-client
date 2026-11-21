import 'package:flutter/material.dart';

import 'package:nmail_core/controllers/backup_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/widgets/controller_builder.dart';
import 'widgets/settings_action_tile.dart';
import 'widgets/settings_group.dart';

class BackupSettingsView extends StatelessWidget {
  const BackupSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ControllerBuilder(
      create: BackupController.new,
      builder: (context, controller) => Scaffold(
        appBar: AppBar(title: Text(l.settingsBackup)),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      l.backupIntro,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SettingsGroup(
                    rows: [
                      (index, count) => SettingsActionTile(
                        icon: Icons.file_download_outlined,
                        title: l.backupExport,
                        subtitle: l.backupExportSubtitle,
                        isBusy: controller.isExporting,
                        index: index,
                        count: count,
                        onTap: controller.isBusy
                            ? null
                            : () => controller.exportBackup(context),
                      ),
                      (index, count) => SettingsActionTile(
                        icon: Icons.restore,
                        title: l.backupRestore,
                        subtitle: l.backupRestoreSubtitle,
                        isBusy: controller.isRestoring,
                        index: index,
                        count: count,
                        onTap: controller.isBusy
                            ? null
                            : () => controller.restoreBackup(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
