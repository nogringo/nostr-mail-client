import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/prepare_email_html.dart';

void main() {
  group('oversized HTML (past _maxHtmlLength)', () {
    final big = '<html><body>${'<p>x</p>' * 900000}'
        '<style>div.a > div.b > span.c { color: red }</style>'
        '<p style="color: blue">styled</p></body></html>';

    test('style blocks and attributes are stripped, not passed raw', () {
      expect(big.length, greaterThan(2 * 1024 * 1024));
      final out = prepareEmailHtml(big, allowRemoteImages: false);
      expect(out.html.contains('<style'), isFalse);
      expect(out.html.contains('style='), isFalse);
      // The markup itself survives.
      expect(out.html.contains('<p>x</p>'), isTrue);
    });

    test('remote-image flag is still computed on the oversized path', () {
      final withImg = '<img src="https://tracker.example/pixel.png">' '${'q' * (2 * 1024 * 1024)}';
      final out = prepareEmailHtml(withImg, allowRemoteImages: false);
      expect(out.hasRemoteImages, isTrue);
    });

    test('quoted HTML is stripped too, not returned raw', () {
      final out = prepareQuotedHtml(big);
      expect(out.contains('<style'), isFalse);
      expect(out.contains('style='), isFalse);
    });

    test('normal-size mail keeps its styles', () {
      final out = prepareEmailHtml(
        '<style>p { color: red }</style><p style="color: blue">hi</p>',
        allowRemoteImages: false,
      );
      expect(out.html, contains('color'));
    });
  });
}
