import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/controllers/custom_color_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';

class HueSlider extends StatelessWidget {
  final CustomColorController controller;

  const HueSlider({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Obx(
      () => SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 12,
          trackShape: const _HueTrackShape(),
          thumbColor: controller.color.value,
        ),
        child: Slider(
          value: controller.hue.value,
          max: 360,
          onChanged: controller.setHue,
          label: l.mailboxColorHue,
          showValueIndicator: ShowValueIndicator.never,
          semanticFormatterCallback: (value) => '${value.round()}°',
        ),
      ),
    );
  }
}

class _HueTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _HueTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final hues = [
      for (var hue = 0.0; hue <= 360; hue += 30)
        CustomColorController.colorAtHue(hue % 360),
    ];
    final paint = Paint()
      ..shader = LinearGradient(
        colors: textDirection == TextDirection.ltr
            ? hues
            : hues.reversed.toList(),
      ).createShader(rect);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
      paint,
    );
  }
}
