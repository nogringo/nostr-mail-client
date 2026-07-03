import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../../controllers/nip65_relays_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import 'recommendation_chips.dart';

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
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                l.relayDirection,
                style: TextStyle(
                  fontSize: 12,
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
                l.relayInboxOutboxTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => _addRelay(context, controller),
                tooltip: l.relayAddTooltip,
              ),
            ),
            RecommendationChips(
              recommendations: NostrConfig.recommendedInboxOutboxRelays,
              isAlreadyAdded: (relay) =>
                  controller.relays != null &&
                  controller.relays!.containsKey(relay),
              onAdd: controller.addRecommendedRelay,
              formatLabel: formatRelayUrl,
            ),
            if (controller.relays == null || controller.relays!.isEmpty)
              ListTile(
                leading: const Icon(Icons.warning_rounded),
                title: Text(l.relayInboxOutboxEmpty),
                subtitle: Text(l.relayEmptyHint),
              )
            else
              ...controller.relays!.entries.map((entry) {
                final relay = entry.key;
                final marker = entry.value;
                final isMarked = controller.markedForDeletion.contains(relay);

                return ListTile(
                  leading: Icon(
                    Icons.dns_outlined,
                    color: isMarked ? Theme.of(context).disabledColor : null,
                  ),
                  title: Text(
                    formatRelayUrl(relay),
                    style: TextStyle(
                      fontSize: 14,
                      decoration: isMarked ? TextDecoration.lineThrough : null,
                      color: isMarked ? Theme.of(context).disabledColor : null,
                    ),
                  ),
                  subtitle: GestureDetector(
                    onTap: isMarked
                        ? null
                        : () => controller.cycleMarker(relay),
                    child: Text(
                      _markerLabel(l, marker),
                      style: TextStyle(
                        fontSize: 12,
                        color: isMarked
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(isMarked ? Icons.undo : Icons.close, size: 18),
                    onPressed: () => controller.toggleRelayDeletion(relay),
                    tooltip: isMarked ? l.actionUndo : l.relayRemoveTooltip,
                  ),
                );
              }),
            if (controller.hasChanges)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isSaving
                        ? null
                        : controller.saveChanges,
                    child: controller.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.actionSave),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
