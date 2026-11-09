import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/safe_filename.dart';

void main() {
  group('safeFilename', () {
    test('keeps ordinary names', () {
      expect(safeFilename('invoice-2026.pdf'), 'invoice-2026.pdf');
      expect(safeFilename('photo (1).JPG'), 'photo (1).JPG');
      expect(safeFilename('résumé été.docx'), 'résumé été.docx');
      expect(safeFilename('.gitignore'), '.gitignore');
    });

    test('strips bidi controls that spoof the extension', () {
      expect(safeFilename('invoice\u202Efdp.exe'), 'invoicefdp.exe');
      expect(safeFilename('x.p\u202Edf'), 'x.pdf');
      expect(safeFilename('a\u2066b\u2069\u200E\u200F\u061C.txt'), 'ab.txt');
    });

    test('strips C0 and C1 control characters', () {
      expect(safeFilename('bad\u0000\u0007\nname\u0085.txt'), 'badname.txt');
    });

    test('replaces separators and Windows reserved characters', () {
      expect(safeFilename('../../.bashrc'), '.._.._.bashrc');
      expect(safeFilename(r'..\..\evil.exe'), '.._.._evil.exe');
      expect(safeFilename('a.txt:Zone.Identifier'), 'a.txt_Zone.Identifier');
      expect(safeFilename('<a>|"b"?*.txt'), '_a___b___.txt');
    });

    test('drops trailing dots and spaces', () {
      expect(safeFilename('evil.exe. . '), 'evil.exe');
    });

    test('returns null when nothing usable is left', () {
      for (final name in [null, '', '   ', '.', '..', '...', '\u202E']) {
        expect(safeFilename(name), isNull, reason: name);
      }
    });

    test('caps at 255 UTF-8 bytes and keeps the extension', () {
      expect(safeFilename('${'文' * 200}.pdf'), '${'文' * 83}.pdf');
    });

    test('never splits a character when truncating', () {
      expect(
        safeFilename('${'\u{1F600}' * 200}.txt'),
        '${'\u{1F600}' * 62}.txt',
      );
    });

    test('caps names whose extension alone exceeds the limit', () {
      final out = safeFilename('a.${'b' * 300}')!;
      expect(out, 'a.${'b' * 253}');
      expect(utf8.encode(out).length, 255);
    });
  });
}
