import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/models/sync_code_kind.dart';

void main() {
  group('SyncCodeKind.of', () {
    test('detects each pasted format', () {
      expect(SyncCodeKind.of('nsec1abc'), SyncCodeKind.nsec);
      expect(SyncCodeKind.of('ncryptsec1abc'), SyncCodeKind.ncryptsec);
      expect(
        SyncCodeKind.of('bunker://abc?relay=wss://relay.example'),
        SyncCodeKind.bunker,
      );
    });

    test('ignores surrounding whitespace', () {
      expect(SyncCodeKind.of('  ncryptsec1abc\n'), SyncCodeKind.ncryptsec);
    });

    test('returns null for anything else', () {
      expect(SyncCodeKind.of(''), isNull);
      expect(SyncCodeKind.of('npub1abc'), isNull);
      expect(SyncCodeKind.of('nostrconnect://abc'), isNull);
    });
  });
}
