import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../../controllers/blossom_servers_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/blossom_utils.dart';
import 'hosting_add_tile.dart';
import 'hosting_empty_tile.dart';
import 'hosting_loading_tile.dart';
import 'hosting_resource_tile.dart';
import 'recommendation_chips.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';

class BlossomServersSection extends StatelessWidget {
  const BlossomServersSection({super.key});

  Future<void> _addServer(
    BuildContext context,
    BlossomServersController blossomServersController,
  ) async {
    final l = AppLocalizations.of(context);
    final inputController = TextEditingController();
    String? errorText;
    String? preview;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.blossomAddTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: l.blossomServerUrlHint,
                  labelText: l.blossomServerUrlLabel,
                  errorText: errorText,
                ),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(
                    RegExp(r'\s'),
                    replacementString: '',
                  ),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    errorText = null;
                    final normalized = normalizeBlossomUrl(value.trim());
                    preview = (normalized != value.trim()) ? normalized : null;
                  });
                },
                onSubmitted: (value) {
                  final url = normalizeBlossomUrl(value.trim());
                  if (!isValidBlossomUrl(url)) {
                    setDialogState(() => errorText = l.blossomInvalidUrl);
                    return;
                  }
                  Navigator.pop(context, url);
                },
              ),
              if (preview != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l.hostingWillBeAddedAs(preview!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            TextButton(
              onPressed: () {
                final url = normalizeBlossomUrl(inputController.text.trim());
                if (!isValidBlossomUrl(url)) {
                  setDialogState(() => errorText = l.blossomInvalidUrl);
                  return;
                }
                Navigator.pop(context, url);
              },
              child: Text(l.actionAdd),
            ),
          ],
        ),
      ),
    );

    if (result != null) blossomServersController.addServer(result);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<BlossomServersController>(
      init: BlossomServersController(),
      builder: (controller) {
        final servers = controller.servers ?? const <String>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(
              title: l.blossomSectionTitle,
              description: l.blossomDescription,
            ),
            if (controller.isLoading)
              const HostingLoadingTile()
            else ...[
              SettingsGroup(
                rows: [
                  if (servers.isEmpty)
                    (index, count) => HostingEmptyTile(
                      icon: Icons.cloud_off_outlined,
                      message: l.blossomEmpty,
                      index: index,
                      count: count,
                    )
                  else
                    for (final server in servers)
                      (index, count) => HostingResourceTile(
                        icon: Icons.cloud_outlined,
                        label: formatBlossomUrl(server),
                        index: index,
                        count: count,
                        isMarkedForDeletion: controller.markedForDeletion
                            .contains(server),
                        removeTooltip: l.blossomRemoveTooltip,
                        onToggleDeletion: () =>
                            controller.toggleServerDeletion(server),
                      ),
                  (index, count) => HostingAddTile(
                    label: l.blossomAdd,
                    index: index,
                    count: count,
                    onTap: () => _addServer(context, controller),
                  ),
                ],
              ),
              RecommendationChips(
                recommendations: NostrConfig.recommendedBlossomServers,
                isAlreadyAdded: servers.contains,
                onAdd: controller.addServer,
                formatLabel: formatBlossomUrl,
              ),
            ],
          ],
        );
      },
    );
  }
}
