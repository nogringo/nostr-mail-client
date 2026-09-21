import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/redact_home_paths.dart';

void main() {
  group('Redact home paths', () {
    test('replaces the account name on macOS and Linux', () {
      expect(
        redactHomePaths(
          "FileSystemException: path = '/Users/olivier/Library/nmail.sqlite'",
        ),
        "FileSystemException: path = '/Users/user/Library/nmail.sqlite'",
      );
      expect(
        redactHomePaths('at /home/olivier/.local/share/nmail'),
        'at /home/user/.local/share/nmail',
      );
    });

    test('replaces the account name on Windows, whatever the drive', () {
      expect(
        redactHomePaths(r'D:\Users\Olivier\AppData\nmail.sqlite'),
        r'D:\Users\user\AppData\nmail.sqlite',
      );
    });

    test('replaces every occurrence in a stack trace', () {
      expect(
        redactHomePaths(
          '#0 open (/Users/olivier/a.dart:1)\n#1 init (/Users/olivier/b.dart:2)',
        ),
        '#0 open (/Users/user/a.dart:1)\n#1 init (/Users/user/b.dart:2)',
      );
    });

    test('leaves paths without an account name alone', () {
      expect(redactHomePaths('/Users/'), '/Users/');
      expect(
        redactHomePaths('package:nmail_core/app/bootstrap.dart 158:7'),
        'package:nmail_core/app/bootstrap.dart 158:7',
      );
    });

    test('leaves a web stack trace untouched', () {
      expect(
        redactHomePaths('packages/drift/src/web/wasm_setup.dart 118:5  open'),
        'packages/drift/src/web/wasm_setup.dart 118:5  open',
      );
    });
  });
}
