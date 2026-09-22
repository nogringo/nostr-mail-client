import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/html_has_images.dart';

void main() {
  group('htmlHasImages', () {
    test('detects an img tag', () {
      expect(htmlHasImages('<p>x</p><img src="https://e.test/p.gif">'), isTrue);
    });

    test('detects a self-closing img tag', () {
      expect(htmlHasImages('<img/>'), isTrue);
    });

    test('detects a background-image declaration', () {
      expect(
        htmlHasImages('<div style="background-image:url(https://e.test/p)">'),
        isTrue,
      );
    });

    test('detects a background shorthand carrying a url', () {
      expect(
        htmlHasImages('<div style="background: #fff url(p.gif) no-repeat">'),
        isTrue,
      );
    });

    test('ignores a background color', () {
      expect(htmlHasImages('<div style="background-color:#fff">'), isFalse);
    });

    test('ignores the word background in text', () {
      expect(htmlHasImages('<p>some background reading</p>'), isFalse);
    });

    test('is false for plain markup', () {
      expect(htmlHasImages('<p>bonjour</p>'), isFalse);
    });
  });
}
