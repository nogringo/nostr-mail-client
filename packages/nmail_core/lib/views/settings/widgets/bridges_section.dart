import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../../controllers/bridges_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'hosting_add_tile.dart';
import 'hosting_empty_tile.dart';
import 'hosting_loading_tile.dart';
import 'hosting_resource_tile.dart';
import 'recommendation_chips.dart';
import 'settings_group.dart';
import 'settings_section_header.dart';

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
        final bridges = controller.bridges ?? const <String>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(
              title: l.bridgeSectionTitle,
              description: l.bridgeDescription,
            ),
            if (controller.isLoading)
              const HostingLoadingTile()
            else ...[
              SettingsGroup(
                rows: [
                  if (bridges.isEmpty)
                    (index, count) => HostingEmptyTile(
                      icon: Icons.alternate_email,
                      message: l.bridgeEmpty,
                      index: index,
                      count: count,
                    )
                  else
                    for (final bridge in bridges)
                      (index, count) => HostingResourceTile(
                        icon: Icons.alternate_email,
                        label: bridge,
                        subtitle: bridge == 'uid.ovh' ? l.bridgeDefault : null,
                        index: index,
                        count: count,
                        isMarkedForDeletion: controller.markedForDeletion
                            .contains(bridge),
                        removeTooltip: l.actionRemove,
                        onToggleDeletion: () =>
                            controller.toggleBridgeDeletion(bridge),
                      ),
                  (index, count) => HostingAddTile(
                    label: l.bridgeAdd,
                    index: index,
                    count: count,
                    onTap: () => _addBridge(context, controller),
                  ),
                ],
              ),
              RecommendationChips(
                recommendations: NostrConfig.recommendedBridges,
                isAlreadyAdded: bridges.contains,
                onAdd: controller.addBridge,
                formatLabel: (bridge) => bridge,
              ),
            ],
          ],
        );
      },
    );
  }
}
