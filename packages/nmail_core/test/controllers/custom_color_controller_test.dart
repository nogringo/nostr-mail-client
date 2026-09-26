import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/controllers/custom_color_controller.dart';

void main() {
  late CustomColorController controller;

  setUp(() {
    controller = CustomColorController(const Color(0xFF039BE5))..onInit();
  });

  tearDown(() => controller.onClose());

  test('opens on the initial color', () {
    expect(controller.hexController.text, '039BE5');
    expect(controller.result, '#039BE5');
  });

  test('moving the hue rewrites the hex code', () {
    controller.setHue(120);
    final hex = controller.hexController.text;
    expect(controller.result, '#$hex');
    expect(HSVColor.fromColor(controller.color.value!).hue, closeTo(120, 1));
  });

  test('an incomplete hex code picks nothing', () {
    controller.setHexDigits('03F');
    expect(controller.result, isNull);
  });

  test('a typed hex code moves the hue', () {
    controller.setHexDigits('ff0000');
    expect(controller.result, '#FF0000');
    expect(controller.hue.value, 0);
  });
}
