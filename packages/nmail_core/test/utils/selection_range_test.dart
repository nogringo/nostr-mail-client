import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/selection_range.dart';

const _ids = ['a', 'b', 'c', 'd', 'e'];

void main() {
  group('idsInRange', () {
    test('covers both bounds when the anchor comes first', () {
      expect(idsInRange(_ids, 'b', 'd'), ['b', 'c', 'd']);
    });

    test('covers both bounds when the anchor comes last', () {
      expect(idsInRange(_ids, 'd', 'b'), ['b', 'c', 'd']);
    });

    test('is the single id when anchor and target match', () {
      expect(idsInRange(_ids, 'c', 'c'), ['c']);
    });

    test('is empty when the anchor is gone', () {
      expect(idsInRange(_ids, 'z', 'c'), isEmpty);
    });

    test('is empty when the target is gone', () {
      expect(idsInRange(_ids, 'c', 'z'), isEmpty);
    });

    test('is empty for an empty list', () {
      expect(idsInRange(const [], 'a', 'b'), isEmpty);
    });
  });
}
