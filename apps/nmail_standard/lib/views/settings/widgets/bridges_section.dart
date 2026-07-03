import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../../controllers/bridges_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'recommendation_chips.dart';

class BridgesSection extends StatelessWidget {
  const BridgesSection({super.key});

  Future<void> _addBridge(
    BuildContext context,
    BridgesController bridgesController,
  ) async {
    final l = AppLocalizations.of(context);
    final inputController = TextEditingController();
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.bridgeAddTitle),
          content: TextField(
            controller: inputController,
            decoration: InputDecoration(
              hintText: l.bridgeDomainHint,
              labelText: l.bridgeDomainLabel,
              errorText: errorText,
            ),
            autofocus: true,
            keyboardType: TextInputType.url,
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
                replacementString: '',
              ),
            ],
            onChanged: (value) {
              setDialogState(() => errorText = null);
            },
            onSubmitted: (value) {
              final domain = value.trim().toLowerCase();
              if (domain.isEmpty || !domain.contains('.')) {
                setDialogState(() => errorText = l.bridgeInvalidDomain);
                return;
              }
              Navigator.pop(context, domain);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionCancel),
            ),
            TextButton(
              onPressed: () {
                final domain = inputController.text.trim().toLowerCase();
                if (domain.isEmpty || !domain.contains('.')) {
                  setDialogState(() => errorText = l.bridgeInvalidDomain);
                  return;
                }
                Navigator.pop(context, domain);
              },
              child: Text(l.actionAdd),
            ),
          ],
        ),
      ),
    );

    if (result != null) bridgesController.addBridge(result);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return GetBuilder<BridgesController>(
      init: BridgesController(),
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
                l.bridgeSectionTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => _addBridge(context, controller),
                tooltip: l.bridgeAddTooltip,
              ),
            ),
            RecommendationChips(
              recommendations: NostrConfig.recommendedBridges,
              isAlreadyAdded: (bridge) =>
                  controller.bridges != null &&
                  controller.bridges!.contains(bridge),
              onAdd: controller.addBridge,
              formatLabel: (bridge) => bridge,
            ),
            if (controller.bridges == null || controller.bridges!.isEmpty)
              ListTile(
                leading: const Icon(Icons.alternate_email),
                title: Text(l.bridgeEmpty),
                subtitle: Text(l.bridgeEmptyHint),
              )
            else
              ...controller.bridges!.map((bridge) {
                final isMarked = controller.markedForDeletion.contains(bridge);
                final isDefault = bridge == 'uid.ovh';

                return ListTile(
                  leading: Icon(
                    Icons.alternate_email,
                    color: isMarked ? Theme.of(context).disabledColor : null,
                  ),
                  title: Text(
                    bridge,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: isMarked ? TextDecoration.lineThrough : null,
                      color: isMarked ? Theme.of(context).disabledColor : null,
                    ),
                  ),
                  subtitle: isDefault
                      ? Text(
                          l.bridgeDefault,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  trailing: IconButton(
                    icon: Icon(isMarked ? Icons.undo : Icons.close, size: 18),
                    onPressed: () => controller.toggleBridgeDeletion(bridge),
                    tooltip: isMarked ? l.actionUndo : l.actionRemove,
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
