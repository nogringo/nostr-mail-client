import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/unique_filename.dart';

void main() {
  group('uniqueFilename', () {
    test('keeps a free name', () {
      expect(uniqueFilename('report.pdf', (_) => false), 'report.pdf');
    });

    test('numbers a taken name before its extension', () {
      final taken = {'report.pdf'};
      expect(uniqueFilename('report.pdf', taken.contains), 'report (1).pdf');
    });

    test('skips numbers already taken', () {
      final taken = {'report.pdf', 'report (1).pdf', 'report (2).pdf'};
      expect(uniqueFilename('report.pdf', taken.contains), 'report (3).pdf');
    });

    test('handles a name without extension', () {
      final taken = {'README'};
      expect(uniqueFilename('README', taken.contains), 'README (1)');
    });
  });
}
