import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/segmented_list_shape.dart';
import 'email_signature_dialog.dart';

class EmailSignatureTile extends StatelessWidget {
  const EmailSignatureTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final settings = GetIt.I<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: segmentedListGap / 2,
      ),
      child: ListenableBuilder(
        listenable: settings.emailSignature,
        builder: (context, _) {
          final signature = settings.signature(l);
          return ListTile(
            tileColor: colorScheme.surfaceContainerHigh,
            shape: segmentedListShape(index: 0, count: 3),
            minTileHeight: 72,
            leading: const Icon(Icons.edit_note),
            title: Text(l.settingsEmailSignature),
            subtitle: Text(
              signature.isEmpty ? l.settingsEmailSignatureEmpty : signature,
            ),
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _edit(context, settings),
          );
        },
      ),
    );
  }

  Future<void> _edit(BuildContext context, SettingsController settings) async {
    final controller = TextEditingController(
      text: settings.signature(AppLocalizations.of(context)),
    );
    final signature = await showDialog<String>(
      context: context,
      builder: (_) => EmailSignatureDialog(controller: controller),
    );
    controller.dispose();
    if (signature != null) await settings.setEmailSignature(signature);
  }
}
