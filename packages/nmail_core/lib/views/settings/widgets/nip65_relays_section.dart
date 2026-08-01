import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../../controllers/nip65_relays_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'hosting_add_tile.dart';
import 'hosting_empty_tile.dart';
import 'hosting_loading_tile.dart';
import 'hosting_resource_tile.dart';
import 'recommendation_chips.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';

class Nip65RelaysSection extends StatelessWidget {
  const Nip65RelaysSection({super.key});

  Future<void> _addRelay(
    BuildContext context,
    Nip65RelaysController nip65RelaysController,
  ) async {
    final l = AppLocalizations.of(context);
    final inputController = TextEditingController();
    String? errorText;
    String? preview;
    ReadWriteMarker marker = ReadWriteMarker.readWrite;

    final result = await showDialog<MapEntry<String, ReadWriteMarker>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.relayAddTitle),
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
                  Navigator.pop(context, MapEntry(url, marker));
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
              const SizedBox(height: 16),
              Text(
                l.relayDirection,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ReadWriteMarker>(
                segments: [
                  ButtonSegment(
                    value: ReadWriteMarker.readWrite,
                    label: Text(l.relayReadWrite),
                  ),
                  ButtonSegment(
                    value: ReadWriteMarker.readOnly,
                    label: Text(l.relayRead),
                  ),
                  ButtonSegment(
                    value: ReadWriteMarker.writeOnly,
                    label: Text(l.relayWrite),
                  ),
                ],
                selected: {marker},
                onSelectionChanged: (selected) {
                  setDialogState(() => marker = selected.first);
                },
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
                Navigator.pop(context, MapEntry(url, marker));
              },
              child: Text(l.actionAdd),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      nip65RelaysController.addRelay(result.key, result.value);
    }
  }

  String _markerLabel(AppLocalizations l, ReadWriteMarker marker) {
    return switch (marker) {
      ReadWriteMarker.readWrite => l.relayMarkerReadWrite,
      ReadWriteMarker.readOnly => l.relayMarkerRead,
      ReadWriteMarker.writeOnly => l.relayMarkerWrite,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<Nip65RelaysController>(
      init: Nip65RelaysController(),
      builder: (controller) {
        final relays = controller.relays ?? const <String, ReadWriteMarker>{};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(
              title: l.relayInboxOutboxTitle,
              description: l.relayInboxOutboxDescription,
            ),
            if (controller.isLoading)
              const HostingLoadingTile()
            else ...[
              SettingsGroup(
                rows: [
                  if (relays.isEmpty)
                    (index, count) => HostingEmptyTile(
                      icon: Icons.warning_amber_rounded,
                      message: l.relayInboxOutboxEmpty,
                      index: index,
                      count: count,
                    )
                  else
                    for (final entry in relays.entries)
                      (index, count) => HostingResourceTile(
                        icon: Icons.dns_outlined,
                        label: formatRelayUrl(entry.key),
                        subtitle: _markerLabel(l, entry.value),
                        index: index,
                        count: count,
                        isMarkedForDeletion: controller.markedForDeletion
                            .contains(entry.key),
                        removeTooltip: l.relayRemoveTooltip,
                        onToggleDeletion: () =>
                            controller.toggleRelayDeletion(entry.key),
                        onTap: () => controller.cycleMarker(entry.key),
                      ),
                  (index, count) => HostingAddTile(
                    label: l.relayAdd,
                    index: index,
                    count: count,
                    onTap: () => _addRelay(context, controller),
                  ),
                ],
              ),
              RecommendationChips(
                recommendations: NostrConfig.recommendedInboxOutboxRelays,
                isAlreadyAdded: relays.containsKey,
                onAdd: controller.addRecommendedRelay,
                formatLabel: formatRelayUrl,
              ),
            ],
          ],
        );
      },
    );
  }
}
