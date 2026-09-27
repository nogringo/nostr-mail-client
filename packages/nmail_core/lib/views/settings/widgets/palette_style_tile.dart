import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'palette_style_picker.dart';
import 'settings_block_tile.dart';

class PaletteStyleTile extends StatelessWidget {
  const PaletteStyleTile({super.key, required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<SettingsController>();

    return Obx(
      () => SettingsBlockTile(
        index: index,
        count: count,
        icon: Icons.palette_outlined,
        label: l.settingsPaletteStyle,
        subtitle: l.settingsPaletteStyleName(
          controller.paletteStyle.value.name,
        ),
        child: const PaletteStylePicker(),
      ),
    );
  }
}
