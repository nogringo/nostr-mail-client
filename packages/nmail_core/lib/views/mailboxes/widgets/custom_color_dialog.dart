import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/custom_color_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'hex_color_field.dart';
import 'hue_slider.dart';

/// Pops with the picked color as `#RRGGBB`.
class CustomColorDialog extends StatelessWidget {
  final CustomColorController controller;

  const CustomColorDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.mailboxColorCustom),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            HueSlider(controller: controller),
            HexColorField(
              controller: controller,
              onSubmitted: () => _submit(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.actionCancel),
        ),
        Obx(
          () => FilledButton(
            onPressed: controller.result == null
                ? null
                : () => _submit(context),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ),
      ],
    );
  }

  void _submit(BuildContext context) {
    final result = controller.result;
    if (result != null) Navigator.pop(context, result);
  }
}
