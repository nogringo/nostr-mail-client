import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'doh_server_dialog.dart';

class DohServerTile extends StatelessWidget {
  const DohServerTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: Obx(
        () => ListTile(
          tileColor: colorScheme.surfaceContainerHigh,
          shape: segmentedListShape(index: 2, count: 3),
          minTileHeight: 72,
          leading: const Icon(Icons.dns_outlined),
          title: Text(l.settingsDohServer),
          subtitle: Text(settings.dohServer.value),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _edit(context, settings),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context, SettingsController settings) async {
    final current = settings.dohServer.value;
    final controller = TextEditingController(
      text: current == SettingsController.defaultDohServer ? '' : current,
    );
    final server = await showDialog<String>(
      context: context,
      builder: (_) => DohServerDialog(controller: controller),
    );
    controller.dispose();
    if (server != null) await settings.setDohServer(server);
  }
}
