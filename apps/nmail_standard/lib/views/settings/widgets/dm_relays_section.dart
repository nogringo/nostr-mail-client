import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/dm_relays_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/relay_utils.dart';
import '../../../app/config/nostr_config.dart';
import 'recommendation_chips.dart';

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
                    style: TextStyle(
                      fontSize: 12,
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
                l.dmRelaySectionTitle,
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
              recommendations: NostrConfig.recommendedDmRelays,
              isAlreadyAdded: (relay) =>
                  controller.dmRelays != null &&
                  controller.dmRelays!.contains(relay),
              onAdd: controller.addRelay,
              formatLabel: formatRelayUrl,
            ),
            if (controller.dmRelays == null || controller.dmRelays!.isEmpty)
              ListTile(
                leading: const Icon(Icons.warning_rounded),
                title: Text(l.dmRelayEmpty),
                subtitle: Text(l.relayEmptyHint),
              )
            else
              ...controller.dmRelays!.map((relay) {
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
