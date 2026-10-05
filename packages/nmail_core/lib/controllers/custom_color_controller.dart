import 'package:flutter/material.dart';

import 'mailboxes_controller.dart';

class CustomColorController extends ChangeNotifier {
  final Color initial;

  CustomColorController(this.initial)
    : hexController = TextEditingController(text: _digits(initial)),
      hue = HSVColor.fromColor(initial).hue,
      color = initial;

  final TextEditingController hexController;
  double hue;

  /// Null while the typed code is not a color.
  Color? color;

  static Color colorAtHue(double hue) =>
      HSVColor.fromAHSV(1, hue, 0.75, 0.85).toColor();

  @override
  void dispose() {
    hexController.dispose();
    super.dispose();
  }

  void setHue(double value) {
    final next = colorAtHue(value);
    hue = value;
    color = next;
    hexController.text = _digits(next);
    notifyListeners();
  }

  void setHexDigits(String digits) {
    final parsed = MailboxesController.parseEntryColor('#$digits');
    color = parsed;
    if (parsed != null) hue = HSVColor.fromColor(parsed).hue;
    notifyListeners();
  }

  /// `#RRGGBB`, or null while the typed code is not a color.
  String? get result {
    final color = this.color;
    return color == null ? null : MailboxesController.formatEntryColor(color);
  }

  static String _digits(Color color) =>
      MailboxesController.formatEntryColor(color).substring(1);
}
