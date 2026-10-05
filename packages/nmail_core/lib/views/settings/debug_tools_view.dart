import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/debug_tools_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/widgets/controller_builder.dart';

class DebugToolsView extends StatelessWidget {
  const DebugToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = GetIt.I<SettingsController>();

    return ControllerBuilder(
      create: DebugToolsController.new,
      builder: (context, controller) => Scaffold(
        appBar: AppBar(title: Text(l.settingsDebugTools)),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 600,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      l.debugToolsEmailTesting,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          controller.createOldTrashedEmail(context),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l.debugToolsCreateOldTrashed),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.debugToolsCreateOldTrashedDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          controller.triggerTestNotification(context),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: Text(l.debugToolsTriggerNotification),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.debugToolsTriggerNotificationDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l.debugToolsSync,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.isClearingSyncCoverage
                          ? null
                          : () => controller.clearSyncCoverage(context),
                      icon: controller.isClearingSyncCoverage
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync_disabled),
                      label: Text(l.debugToolsClearSyncCoverage),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.debugToolsClearSyncCoverageDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (settings.debugToolsUnlocked.value) ...[
                      const Divider(height: 48),
                      ElevatedButton.icon(
                        onPressed: () => controller.hideDebugTools(context),
                        icon: const Icon(Icons.visibility_off_outlined),
                        label: Text(l.debugToolsHide),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.debugToolsHideDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
