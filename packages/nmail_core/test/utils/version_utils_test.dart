import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/version_utils.dart';

void main() {
  group('isNewerVersion', () {
    test('compares each numeric part, not the string', () {
      expect(isNewerVersion('0.10.0', '0.9.0'), isTrue);
      expect(isNewerVersion('1.0.0', '0.16.3'), isTrue);
      expect(isNewerVersion('0.16.1', '0.16.0'), isTrue);
    });

    test('equal or older is not newer', () {
      expect(isNewerVersion('0.16.0', '0.16.0'), isFalse);
      expect(isNewerVersion('0.15.9', '0.16.0'), isFalse);
    });

    test('ignores a leading v and build or prerelease suffixes', () {
      expect(isNewerVersion('v0.17.0', '0.16.0+28'), isTrue);
      expect(isNewerVersion('v0.16.0', '0.16.0+28'), isFalse);
      expect(isNewerVersion('0.17.0-dev.1', '0.16.0'), isTrue);
    });

    test('missing parts count as zero', () {
      expect(isNewerVersion('1.0', '1.0.0'), isFalse);
      expect(isNewerVersion('1.0.1', '1.0'), isTrue);
    });

    test('unparsable input is never newer', () {
      expect(isNewerVersion('nightly', '0.16.0'), isFalse);
      expect(isNewerVersion('0.17.0', ''), isFalse);
    });
  });
}
