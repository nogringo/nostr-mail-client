import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/community_theme.dart';

const _pubkey =
    'b22b06b051fd5232966a9344a634d956c3dc33a7f5ecdcad9ed11ddc4120a7f2';

Nip01Event _event(
  List<List<String>> tags, {
  int createdAt = 1000,
  int kind = CommunityTheme.kind,
}) => Nip01Event(
  pubKey: _pubkey,
  kind: kind,
  tags: tags,
  content: '',
  createdAt: createdAt,
);

List<List<String>> _tags({
  String d = 'mk-dark-theme',
  String background = '#1a1a2e',
  List<List<String>> extra = const [],
}) => [
  ['d', d],
  ['c', background, 'background'],
  ['c', '#e0e0e0', 'text'],
  ['c', '#6c3ce0', 'primary'],
  ['title', 'MK Dark Theme'],
  ...extra,
];

void main() {
  test('parses the colors and derives the scheme from the background', () {
    final theme = CommunityTheme.fromEvent(_event(_tags()))!;

    expect(theme.title, 'MK Dark Theme');
    expect(theme.address, '36767:$_pubkey:mk-dark-theme');
    expect(theme.primary, const Color(0xFF6C3CE0));
    expect(theme.text, const Color(0xFFE0E0E0));
    expect(theme.background, const Color(0xFF1A1A2E));
    expect(theme.brightness, Brightness.dark);
    expect(theme.seedColor, theme.primary);
    expect(theme.variant, DynamicSchemeVariant.fidelity);
    expect(theme.backgroundImageUrl, isNull);
  });

  test('a light background makes a light theme', () {
    final theme = CommunityTheme.fromEvent(
      _event(_tags(background: '#EEE8E1')),
    )!;

    expect(theme.brightness, Brightness.light);
  });

  test('rejects a theme missing a color role, a title or a d tag', () {
    expect(
      CommunityTheme.fromEvent(
        _event(_tags().where((tag) => tag.last != 'text').toList()),
      ),
      isNull,
    );
    expect(
      CommunityTheme.fromEvent(
        _event(_tags().where((tag) => tag.first != 'title').toList()),
      ),
      isNull,
    );
    expect(
      CommunityTheme.fromEvent(
        _event(_tags().where((tag) => tag.first != 'd').toList()),
      ),
      isNull,
    );
  });

  test('rejects malformed hex colors and other kinds', () {
    expect(CommunityTheme.fromEvent(_event(_tags(background: 'red'))), isNull);
    expect(
      CommunityTheme.fromEvent(_event(_tags(background: '#-12345'))),
      isNull,
    );
    expect(CommunityTheme.fromEvent(_event(_tags(), kind: 16767)), isNull);
  });

  test('color-scheme wins over the background luminance', () {
    final theme = CommunityTheme.fromEvent(
      _event(
        _tags(
          extra: [
            ['color-scheme', 'light'],
          ],
        ),
      ),
    )!;

    expect(theme.brightness, Brightness.light);
  });

  test('the material tag sets the seed and the variant', () {
    final theme = CommunityTheme.fromEvent(
      _event(
        _tags(
          extra: [
            ['material', '#20b634', 'fruit-salad'],
          ],
        ),
      ),
    )!;

    expect(theme.seedColor, const Color(0xFF20B634));
    expect(theme.variant, DynamicSchemeVariant.fruitSalad);
  });

  test('an unknown material variant falls back to fidelity', () {
    final theme = CommunityTheme.fromEvent(
      _event(
        _tags(
          extra: [
            ['material', '#20b634', 'sparkly'],
          ],
        ),
      ),
    )!;

    expect(theme.seedColor, const Color(0xFF20B634));
    expect(theme.variant, DynamicSchemeVariant.fidelity);
  });

  test('a grey seed becomes monochrome rather than fidelity', () {
    final theme = CommunityTheme.fromEvent(
      _event([
        ['d', 'black-white'],
        ['c', '#000000', 'background'],
        ['c', '#ffffff', 'text'],
        ['c', '#ffffff', 'primary'],
        ['title', 'Black & White'],
      ]),
    )!;

    expect(theme.variant, DynamicSchemeVariant.monochrome);
  });

  test('keeps an image background and drops a video one', () {
    const url = 'https://example.com/bg.jpg';
    final image = CommunityTheme.fromEvent(
      _event(
        _tags(
          extra: [
            ['bg', 'url $url', 'mode cover', 'm image/jpeg', 'dim 1920x1080'],
          ],
        ),
      ),
    )!;
    final video = CommunityTheme.fromEvent(
      _event(
        _tags(
          extra: [
            [
              'bg',
              'url https://example.com/bg.mp4',
              'mode cover',
              'm video/mp4',
            ],
          ],
        ),
      ),
    )!;

    expect(image.backgroundImageUrl, url);
    expect(video.backgroundImageUrl, isNull);
  });

  test('latest keeps the newest version of each theme, newest first', () {
    final themes = CommunityTheme.latest([
      _event(_tags(d: 'a'), createdAt: 10),
      _event(_tags(d: 'a', background: '#ffffff'), createdAt: 30),
      _event(_tags(d: 'b'), createdAt: 20),
      _event([
        ['d', 'invalid'],
      ], createdAt: 40),
    ]);

    expect(themes.map((theme) => theme.identifier), ['a', 'b']);
    expect(themes.first.background, const Color(0xFFFFFFFF));
  });

  test('withoutCopies keeps the oldest of themes that look the same', () {
    final themes = CommunityTheme.latest([
      _event(_tags(d: 'copy'), createdAt: 30),
      _event(
        _tags(
          d: 'with-image',
          extra: [
            [
              'bg',
              'url https://example.com/bg.jpg',
              'mode cover',
              'm image/jpeg',
            ],
          ],
        ),
        createdAt: 20,
      ),
      _event([
        ['d', 'original'],
        ['c', '#1a1a2e', 'background'],
        ['c', '#ffffff', 'text'],
        ['c', '#6c3ce0', 'primary'],
        ['title', 'Original'],
      ], createdAt: 10),
    ]);

    expect(
      CommunityTheme.withoutCopies(themes).map((theme) => theme.identifier),
      ['with-image', 'original'],
    );
  });
}
