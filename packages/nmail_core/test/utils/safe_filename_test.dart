import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/safe_filename.dart';

void main() {
  group('safeFilename', () {
    test('keeps normal names', () {
      expect(safeFilename('invoice-2026.pdf'), 'invoice-2026.pdf');
      expect(safeFilename('photo (1).jpg'), 'photo (1).jpg');
    });

    test('strips bidi overrides used for extension spoofing', () {
      // U+202E renders "fodne.pdf" as "note.pdf".
      final out = safeFilename('fodne\u202e.pdf');
      expect(out.contains('\u202e'), isFalse);
      expect(out.endsWith('.pdf'), isTrue);
    });

    test('strips isolates and direction marks', () {
      for (final ch in ['\u2066', '\u2067', '\u2068', '\u2069', '\u200e', '\u200f']) {
        expect(safeFilename('a${ch}b.txt').contains(ch), isFalse);
      }
    });

    test('strips control characters', () {
      final out = safeFilename('bad\u0000\u0007\u001bname.txt');
      expect(out, 'badname.txt');
    });

    test('cannot traverse directories', () {
      expect(safeFilename('../../etc/passwd'), contains('_'));
      expect(safeFilename('../../etc/passwd').startsWith('/'), isFalse);
      expect(safeFilename('..\\..\\windows'), isNot(contains('\\')));
    });

    test('dot, dot-dot and empty become the fallback', () {
      expect(safeFilename('..'), isNot('..'));
      expect(safeFilename('.'), isNot('.'));
      expect(safeFilename('   '), isNot(''));
    });

    test('caps the length, keeping the extension', () {
      final out = safeFilename('${'a' * 400}.txt');
      expect(out.length, lessThanOrEqualTo(255));
      expect(out.endsWith('.txt'), isTrue);
    });

    test('defuses Windows reserved names', () {
      expect(safeFilename('CON.txt'), startsWith('_'));
      expect(safeFilename('nul'), startsWith('_'));
      expect(safeFilename('report.txt'), isNot(startsWith('_')));
    });
  });
}
