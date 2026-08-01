import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/dm_relays_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'package:nmail_core/config/nostr_config.dart';
import 'hosting_add_tile.dart';
import 'hosting_empty_tile.dart';
import 'hosting_loading_tile.dart';
import 'hosting_resource_tile.dart';
import 'recommendation_chips.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';

class DmRelaysSection extends StatelessWidget {
  const DmRelaysSection({super.key});

  Future<void> _addRelay(
    BuildContext context,
    DmRelaysController dmRelaysController,
  ) async {
    final l = AppLocalizations.of(context);
    final inputController = TextEditingController();
    String? errorText;
    String? preview;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.dmRelayAddTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: inputController,
                decoration: InputDecoration(
                  hintText: l.relayUrlHint,
                  labelText: l.relayUrlLabel,
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
                    final normalized = normalizeRelayUrl(value.trim());
                    preview = (normalized != value.trim()) ? normalized : null;
                  });
                },
                onSubmitted: (value) {
                  final url = normalizeRelayUrl(value.trim());
                  if (!isValidRelayUrl(url)) {
                    setDialogState(() => errorText = l.relayInvalidUrl);
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
                final url = normalizeRelayUrl(inputController.text.trim());
                if (!isValidRelayUrl(url)) {
                  setDialogState(() => errorText = l.relayInvalidUrl);
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

    if (result != null) dmRelaysController.addRelay(result);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<DmRelaysController>(
      init: DmRelaysController(),
      builder: (controller) {
        final relays = controller.dmRelays ?? const <String>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(
              title: l.dmRelaySectionTitle,
              description: l.dmRelayDescription,
            ),
            if (controller.isLoading)
              const HostingLoadingTile()
            else ...[
              SettingsGroup(
                rows: [
                  if (relays.isEmpty)
                    (index, count) => HostingEmptyTile(
                      icon: Icons.warning_amber_rounded,
                      message: l.dmRelayEmpty,
                      index: index,
                      count: count,
                    )
                  else
                    for (final relay in relays)
                      (index, count) => HostingResourceTile(
                        icon: Icons.dns_outlined,
                        label: formatRelayUrl(relay),
                        index: index,
                        count: count,
                        isMarkedForDeletion: controller.markedForDeletion
                            .contains(relay),
                        removeTooltip: l.relayRemoveTooltip,
                        onToggleDeletion: () =>
                            controller.toggleRelayDeletion(relay),
                      ),
                  (index, count) => HostingAddTile(
                    label: l.dmRelayAdd,
                    index: index,
                    count: count,
                    onTap: () => _addRelay(context, controller),
                  ),
                ],
              ),
              RecommendationChips(
                recommendations: NostrConfig.recommendedDmRelays,
                isAlreadyAdded: relays.contains,
                onAdd: controller.addRelay,
                formatLabel: formatRelayUrl,
              ),
            ],
          ],
        );
      },
    );
  }
}
