import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/config/nostr_config.dart';
import '../../../controllers/blossom_servers_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/blossom_utils.dart';
import 'recommendation_chips.dart';

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
                l.blossomSectionTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => _addServer(context, controller),
                tooltip: l.blossomAddTooltip,
              ),
            ),
            RecommendationChips(
              recommendations: NostrConfig.recommendedBlossomServers,
              isAlreadyAdded: (server) =>
                  controller.servers != null &&
                  controller.servers!.contains(server),
              onAdd: controller.addServer,
              formatLabel: formatBlossomUrl,
            ),
            if (controller.servers == null || controller.servers!.isEmpty)
              ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: Text(l.blossomEmpty),
                subtitle: Text(l.blossomEmptyHint),
              )
            else
              ...controller.servers!.map((server) {
                final isMarked = controller.markedForDeletion.contains(server);

                return ListTile(
                  leading: Icon(
                    Icons.cloud_outlined,
                    color: isMarked ? Theme.of(context).disabledColor : null,
                  ),
                  title: Text(
                    formatBlossomUrl(server),
                    style: TextStyle(
                      fontSize: 14,
                      decoration: isMarked ? TextDecoration.lineThrough : null,
                      color: isMarked ? Theme.of(context).disabledColor : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(isMarked ? Icons.undo : Icons.close, size: 18),
                    onPressed: () => controller.toggleServerDeletion(server),
                    tooltip: isMarked ? l.actionUndo : l.blossomRemoveTooltip,
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
