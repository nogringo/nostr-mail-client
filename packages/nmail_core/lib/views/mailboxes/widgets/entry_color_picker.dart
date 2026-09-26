import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'entry_color_swatch.dart';
import 'show_custom_color_dialog.dart';

class EntryColorPicker extends StatelessWidget {
  final MailEntryFormController controller;

  const EntryColorPicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final palette = MailEntryFormController.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(l.mailboxColor, style: Theme.of(context).textTheme.titleSmall),
        Obx(() {
          final custom = controller.customColor.value;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              EntryColorSwatch(
                color: null,
                label: l.mailboxColorAuto,
                selected: controller.color.value == null,
                onTap: () => controller.color.value = null,
              ),
              for (final (index, hex) in palette.indexed)
                EntryColorSwatch(
                  color: MailboxesController.parseEntryColor(hex),
                  label: l.mailboxColorOption(index + 1),
                  selected: controller.color.value?.toUpperCase() == hex,
                  onTap: () => controller.color.value = hex,
                ),
              if (custom != null)
                EntryColorSwatch(
                  color: MailboxesController.parseEntryColor(custom),
                  label: l.mailboxColorCustom,
                  selected: controller.color.value == custom,
                  onTap: () => controller.color.value = custom,
                ),
            ],
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.palette_outlined),
          label: Text(l.mailboxColorCustom),
          onPressed: () => _pickCustomColor(context),
        ),
      ],
    );
  }

  Future<void> _pickCustomColor(BuildContext context) async {
    final hex = await showCustomColorDialog(
      context,
      initial: controller.customColorSeed,
    );
    if (hex != null) controller.pickCustomColor(hex);
  }
}
