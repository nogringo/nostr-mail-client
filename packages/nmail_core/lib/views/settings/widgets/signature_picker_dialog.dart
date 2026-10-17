import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/controllers/signatures_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'settings_group.dart';
import 'signature_option_tile.dart';

class SignaturePickerDialog extends StatelessWidget {
  const SignaturePickerDialog({
    super.key,
    required this.title,
    required this.selectedId,
    this.inheritLabel,
  });

  final String title;
  final String? selectedId;
  final String? inheritLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final signatures = GetIt.I<SignaturesController>().signatures;
    final inherit = inheritLabel;

    return AlertDialog(
      // The default dialog surface is surfaceContainerHigh, the tile colour itself.
      backgroundColor: colorScheme.surfaceContainerLow,
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsGroup(
                rows: [
                  if (inherit != null)
                    (index, count) => SignatureOptionTile(
                      id: null,
                      label: inherit,
                      isSelected: selectedId == null,
                      index: index,
                      count: count,
                    ),
                  (index, count) => SignatureOptionTile(
                    id: '',
                    label: l.signatureNone,
                    isSelected: selectedId == '',
                    index: index,
                    count: count,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SettingsGroup(
                rows: [
                  for (final signature in signatures)
                    (index, count) => SignatureOptionTile(
                      id: signature.id,
                      label: signature.name,
                      isSelected: selectedId == signature.id,
                      index: index,
                      count: count,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }
}
