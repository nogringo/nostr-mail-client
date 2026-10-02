import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/models/theme_color_family.dart';

/// A shareable theme from the Profile Themes spec (kind 36767).
class CommunityTheme {
  const CommunityTheme({
    required this.pubkey,
    required this.identifier,
    required this.createdAt,
    required this.title,
    required this.primary,
    required this.text,
    required this.background,
    required this.brightness,
    required this.seedColor,
    required this.variant,
    required this.colorFamily,
    this.backgroundImageUrl,
  });

  static const kind = 36767;

  static final _hexColor = RegExp(r'^#[0-9a-fA-F]{6}$');

  final String pubkey;
  final String identifier;
  final int createdAt;
  final String title;
  final Color primary;
  final Color text;
  final Color background;
  final Brightness brightness;
  final Color seedColor;
  final DynamicSchemeVariant variant;
  final ThemeColorFamily colorFamily;
  final String? backgroundImageUrl;

  String get address => '$kind:$pubkey:$identifier';

  ColorScheme get colorScheme => ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: variant,
  );

  static CommunityTheme? fromEvent(Nip01Event event) {
    if (event.kind != kind) return null;

    final colors = <String, Color>{};
    String? identifier;
    String? title;
    Brightness? scheme;
    Color? materialSeed;
    DynamicSchemeVariant? materialVariant;
    String? imageUrl;

    for (final tag in event.tags) {
      if (tag.length < 2) continue;
      switch (tag[0]) {
        case 'd':
          identifier = tag[1];
        case 'title':
          title = tag[1].trim();
        case 'c' when tag.length >= 3:
          final color = _parseColor(tag[1]);
          if (color != null) colors[tag[2]] = color;
        case 'color-scheme':
          scheme = switch (tag[1]) {
            'light' => Brightness.light,
            'dark' => Brightness.dark,
            _ => null,
          };
        case 'material':
          materialSeed = _parseColor(tag[1]);
          materialVariant = tag.length >= 3 ? _parseVariant(tag[2]) : null;
        case 'bg':
          imageUrl = _imageUrl(tag);
      }
    }

    final primary = colors['primary'];
    final text = colors['text'];
    final background = colors['background'];
    if (identifier == null ||
        title == null ||
        title.isEmpty ||
        primary == null ||
        text == null ||
        background == null) {
      return null;
    }

    final seedColor = materialSeed ?? primary;
    final colorFamily = ThemeColorFamily.of(seedColor);

    return CommunityTheme(
      pubkey: event.pubKey,
      identifier: identifier,
      createdAt: event.createdAt,
      title: title,
      primary: primary,
      text: text,
      background: background,
      brightness: scheme ?? ThemeData.estimateBrightnessForColor(background),
      seedColor: seedColor,
      // Fidelity stays close to the author's color. Any variant but
      // monochrome would invent a hue for a gray seed.
      variant:
          (materialSeed != null ? materialVariant : null) ??
          (colorFamily == ThemeColorFamily.gray
              ? DynamicSchemeVariant.monochrome
              : DynamicSchemeVariant.fidelity),
      colorFamily: colorFamily,
      backgroundImageUrl: imageUrl,
    );
  }

  /// Keeps the newest version of each theme, newest first.
  static List<CommunityTheme> latest(Iterable<Nip01Event> events) {
    final byAddress = <String, CommunityTheme>{};
    for (final event in events) {
      final theme = fromEvent(event);
      if (theme == null) continue;
      final current = byAddress[theme.address];
      if (current == null || current.createdAt < theme.createdAt) {
        byAddress[theme.address] = theme;
      }
    }
    return byAddress.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Keeps the oldest of the themes that look the same in Nmail, in order.
  static List<CommunityTheme> withoutCopies(List<CommunityTheme> themes) {
    final originals = <Object, CommunityTheme>{};
    for (final theme in themes) {
      final original = originals[theme._look];
      if (original == null || theme.createdAt < original.createdAt) {
        originals[theme._look] = theme;
      }
    }
    final kept = originals.values.toSet();
    return themes.where(kept.contains).toList();
  }

  Object get _look => (seedColor, variant, brightness, backgroundImageUrl);

  static Color? _parseColor(String hex) {
    if (!_hexColor.hasMatch(hex)) return null;
    return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
  }

  static DynamicSchemeVariant? _parseVariant(String name) {
    final camelCase = name.replaceAllMapped(
      RegExp(r'-(\w)'),
      (match) => match[1]!.toUpperCase(),
    );
    return DynamicSchemeVariant.values.asNameMap()[camelCase];
  }

  /// Video backgrounds are not rendered.
  static String? _imageUrl(List<String> tag) {
    final fields = <String, String>{};
    for (final entry in tag.skip(1)) {
      final space = entry.indexOf(' ');
      if (space > 0) {
        fields[entry.substring(0, space)] = entry.substring(space + 1);
      }
    }
    final url = fields['url'];
    final isImage = fields['m']?.startsWith('image/') ?? false;
    return url != null && isImage && Uri.tryParse(url)?.hasScheme == true
        ? url
        : null;
  }
}
