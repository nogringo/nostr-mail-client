import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:system_theme/system_theme.dart';

import 'package:nmail_core/controllers/mail_entry_form_controller.dart';
import 'package:nmail_core/controllers/mailboxes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import '../../mailboxes/widgets/entry_color_swatch.dart';
import '../../mailboxes/widgets/show_custom_color_dialog.dart';

class ThemeColorPicker extends StatelessWidget {
  const ThemeColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = GetIt.I<SettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([
            controller.themeColor,
            controller.customThemeColor,
          ]),
          builder: (context, _) {
            final selected = controller.themeColor.value?.toUpperCase();
            final custom = controller.customThemeColor.value;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EntryColorSwatch(
                  color: SystemTheme.accentColor.accent,
                  label: l.settingsBackgroundDefaultLabel,
                  selected: selected == null,
                  onTap: () => controller.setThemeColor(null),
                ),
                for (final MapEntry(key: hex, value: name)
                    in MailEntryFormController.palette.entries)
                  EntryColorSwatch(
                    color: MailboxesController.parseEntryColor(hex),
                    label: l.colorName(name),
                    selected: selected == hex,
                    onTap: () => controller.setThemeColor(hex),
                  ),
                if (custom != null)
                  EntryColorSwatch(
                    color: MailboxesController.parseEntryColor(custom),
                    label: l.mailboxColorCustom,
                    selected: selected == custom.toUpperCase(),
                    onTap: () => controller.setThemeColor(custom),
                  ),
              ],
            );
          },
        ),
        TextButton.icon(
          icon: const Icon(Icons.palette_outlined),
          label: Text(l.mailboxColorCustom),
          onPressed: () => _pickCustomColor(context, controller),
        ),
      ],
    );
  }

  Future<void> _pickCustomColor(
    BuildContext context,
    SettingsController controller,
  ) async {
    final hex = await showCustomColorDialog(
      context,
      initial: controller.customThemeColorSeed,
    );
    if (hex != null) await controller.pickCustomThemeColor(hex);
  }
}
