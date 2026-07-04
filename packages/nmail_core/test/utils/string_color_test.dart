import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/string_color.dart';

void main() {
  group('String color', () {
    test('derives the protocol color for Alice email', () {
      expect(getStringColor('aliceo@gmail.com'), const Color(0xFFE64598));
    });

    test('normalizes string case and surrounding whitespace', () {
      expect(
        getStringColor(' AliceO@Gmail.com '),
        getStringColor('aliceo@gmail.com'),
      );
    });

    test('returns neutral grey for empty strings', () {
      expect(getStringColor('  '), const Color(0xFF808080));
    });

    test('hashes normalized UTF-8 bytes for non-ASCII strings', () {
      expect(getStringColor('é'), const Color(0xFFE64568));
    });

    test('parses hex strings directly', () {
      expect(getStringColor('ff'), const Color(0xFF7449F5));
    });
  });
}
