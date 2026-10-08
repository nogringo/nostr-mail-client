import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import '../../../controllers/private_relays_controller.dart';
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

class PrivateRelaysSection extends StatelessWidget {
  const PrivateRelaysSection({super.key});

  Future<void> _addRelay(
    BuildContext context,
    PrivateRelaysController privateRelaysController,
  ) async {
    final l = AppLocalizations.of(context);
    final inputController = TextEditingController();
    String? errorText;
    String? preview;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.privateRelayAddTitle),
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

    if (result != null) privateRelaysController.addRelay(result);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    final controller = GetIt.I<PrivateRelaysController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final relays = controller.privateRelays ?? const <String>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionHeader(
              title: l.privateRelaySectionTitle,
              description: l.privateRelayDescription,
            ),
            if (controller.isLoading)
              const HostingLoadingTile()
            else if (controller.hasLoadFailed)
              SettingsGroup(
                rows: [
                  (index, count) => HostingEmptyTile(
                    icon: Icons.error_outline,
                    message: l.privateRelayLoadFailed,
                    index: index,
                    count: count,
                  ),
                ],
              )
            else ...[
              SettingsGroup(
                rows: [
                  if (relays.isEmpty)
                    (index, count) => HostingEmptyTile(
                      icon: Icons.info_outline,
                      message: l.privateRelayEmpty,
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
                    label: l.privateRelayAdd,
                    index: index,
                    count: count,
                    onTap: () => _addRelay(context, controller),
                  ),
                ],
              ),
              RecommendationChips(
                recommendations: NostrConfig.recommendedPrivateRelays,
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
