import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/html_image_scan.dart';

void main() {
  group('htmlHasRemoteImages', () {
    test('detects an img tag', () {
      expect(
        htmlHasRemoteImages('<p>x</p><img src="https://e.test/p.gif">'),
        isTrue,
      );
    });

    test('reads a single-quoted src', () {
      expect(htmlHasRemoteImages("<img src='https://e.test/p.gif'>"), isTrue);
    });

    test('reads an unquoted src', () {
      expect(htmlHasRemoteImages('<img src=https://e.test/p.gif>'), isTrue);
    });

    test('ignores an img tag carrying no src', () {
      expect(htmlHasRemoteImages('<img/>'), isFalse);
    });

    test('ignores a cid reference', () {
      expect(htmlHasRemoteImages('<img src="cid:logo@nmail">'), isFalse);
    });

    test('ignores a data uri', () {
      expect(
        htmlHasRemoteImages('<img src="data:image/png;base64,iVBORw0K">'),
        isFalse,
      );
    });

    test('is true as soon as one image among inline ones is remote', () {
      const html =
          '<img src="cid:logo@nmail"><img src="https://e.test/pixel.gif">';
      expect(htmlHasRemoteImages(html), isTrue);
    });

    test('reads past a closing bracket written inside an attribute', () {
      const html = '<img alt="a>b" src="https://tracker.test/p.gif">';
      expect(htmlHasRemoteImages(html), isTrue);
    });

    test('detects a background-image declaration', () {
      expect(
        htmlHasRemoteImages(
          '<div style="background-image:url(https://e.test/p)">',
        ),
        isTrue,
      );
    });

    test('detects a background shorthand carrying a url', () {
      expect(
        htmlHasRemoteImages(
          '<div style="background: #fff url(p.gif) no-repeat">',
        ),
        isTrue,
      );
    });

    test('ignores a background pointing at a message part', () {
      expect(
        htmlHasRemoteImages('<div style="background-image:url(cid:hero@x)">'),
        isFalse,
      );
    });

    test('ignores a background color', () {
      expect(htmlHasRemoteImages('<div style="background-color:#fff">'), false);
    });

    test('ignores the word background in text', () {
      expect(htmlHasRemoteImages('<p>some background reading</p>'), isFalse);
    });

    test('is false for plain markup', () {
      expect(htmlHasRemoteImages('<p>bonjour</p>'), isFalse);
    });
  });

  group('htmlInlineImageCids', () {
    test('collects the referenced content ids', () {
      const html = '<img src="cid:logo@nmail"><p>x</p><img src="cid:hero@x">';
      expect(htmlInlineImageCids(html), {'logo@nmail', 'hero@x'});
    });

    test('normalizes case, escapes and angle brackets', () {
      const html = '<img src="CID:%3CLogo%40Nmail%3E">';
      expect(htmlInlineImageCids(html), {'logo@nmail'});
    });

    test('reads past a closing bracket written inside an attribute', () {
      const html = "<img alt='a>b' src='cid:logo@nmail'>";
      expect(htmlInlineImageCids(html), {'logo@nmail'});
    });

    test('ignores remote and data sources', () {
      const html =
          '<img src="https://e.test/p.gif"><img src="data:image/png;base64,A">';
      expect(htmlInlineImageCids(html), isEmpty);
    });

    test('deduplicates a content id used twice', () {
      const html = '<img src="cid:logo@x"><img src="cid:logo@x">';
      expect(htmlInlineImageCids(html), hasLength(1));
    });

    test('is empty for plain markup', () {
      expect(htmlInlineImageCids('<p>bonjour</p>'), isEmpty);
    });
  });
}
