import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/custom_color_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class HexColorField extends StatelessWidget {
  final CustomColorController controller;
  final VoidCallback onSubmitted;

  const HexColorField({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  static const _previewSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller.hexController,
      onChanged: controller.setHexDigits,
      onSubmitted: (_) => onSubmitted(),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        labelText: l.mailboxColorHex,
        prefixText: '#',
        prefixIcon: ExcludeSemantics(
          child: Center(
            widthFactor: 1,
            child: Obx(
              () => Material(
                color:
                    controller.color.value ??
                    colorScheme.surfaceContainerHighest,
                shape: CircleBorder(
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: const SizedBox.square(dimension: _previewSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
