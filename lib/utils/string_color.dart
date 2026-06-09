import 'dart:convert';

import 'package:flutter/material.dart';

const _neutralStringColor = Color(0xFF808080);

Color getStringColor(String input) {
  final normalized = input.trim().toUpperCase();
  if (normalized.isEmpty) return _neutralStringColor;

  final isHex = RegExp(r'^[0-9A-F]+$').hasMatch(normalized);
  final number = isHex
      ? BigInt.parse(normalized, radix: 16)
      : _hashStringToBigInt(normalized);
  final hue = (number % BigInt.from(360)).toInt();
  return _hsvToRgb(hue, isHex: isHex);
}

Color adjustStringColorForText(Color color, Brightness brightness) {
  final factor = brightness == Brightness.dark ? 1.08 : 0.95;
  return Color.fromARGB(
    (color.a * 255).round(),
    _clampChannel(color.r * 255 * factor),
    _clampChannel(color.g * 255 * factor),
    _clampChannel(color.b * 255 * factor),
  );
}

BigInt _hashStringToBigInt(String value) {
  var number = BigInt.zero;
  var multiplier = BigInt.one;
  for (final byte in utf8.encode(value)) {
    number += BigInt.from(byte) * multiplier;
    multiplier *= BigInt.from(256);
  }
  return number;
}

Color _hsvToRgb(int hue, {required bool isHex}) {
  const saturation = 0.70;
  final value = switch (hue) {
    >= 32 && <= 204 => isHex ? 0.75 : 0.70,
    >= 216 && <= 273 => 0.96,
    _ => 0.90,
  };

  final h = hue / 60;
  final chroma = value * saturation;
  final x = chroma * (1 - ((h % 2) - 1).abs());
  final m = value - chroma;
  final (r, g, b) = switch (h) {
    >= 0 && < 1 => (chroma, x, 0.0),
    >= 1 && < 2 => (x, chroma, 0.0),
    >= 2 && < 3 => (0.0, chroma, x),
    >= 3 && < 4 => (0.0, x, chroma),
    >= 4 && < 5 => (x, 0.0, chroma),
    _ => (chroma, 0.0, x),
  };

  return Color.fromARGB(
    255,
    ((r + m) * 255).round(),
    ((g + m) * 255).round(),
    ((b + m) * 255).round(),
  );
}

int _clampChannel(double value) => value.round().clamp(0, 255).toInt();
