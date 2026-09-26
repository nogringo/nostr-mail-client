import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'mailboxes_controller.dart';

class CustomColorController extends GetxController {
  final Color initial;

  CustomColorController(this.initial);

  late final TextEditingController hexController;
  final hue = 0.0.obs;

  /// Null while the typed code is not a color.
  final color = Rxn<Color>();

  static Color colorAtHue(double hue) =>
      HSVColor.fromAHSV(1, hue, 0.75, 0.85).toColor();

  @override
  void onInit() {
    super.onInit();
    hexController = TextEditingController(text: _digits(initial));
    color.value = initial;
    hue.value = HSVColor.fromColor(initial).hue;
  }

  @override
  void onClose() {
    hexController.dispose();
    super.onClose();
  }

  void setHue(double value) {
    final next = colorAtHue(value);
    hue.value = value;
    color.value = next;
    hexController.text = _digits(next);
  }

  void setHexDigits(String digits) {
    final parsed = MailboxesController.parseEntryColor('#$digits');
    color.value = parsed;
    if (parsed != null) hue.value = HSVColor.fromColor(parsed).hue;
  }

  /// `#RRGGBB`, or null while the typed code is not a color.
  String? get result {
    final color = this.color.value;
    return color == null ? null : MailboxesController.formatEntryColor(color);
  }

  static String _digits(Color color) =>
      MailboxesController.formatEntryColor(color).substring(1);
}
