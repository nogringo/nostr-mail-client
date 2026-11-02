import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/blossom_utils.dart';

void main() {
  group('Blossom Utils', () {
    group('formatBlossomUrl', () {
      test('should remove https:// prefix', () {
        expect(
          formatBlossomUrl('https://blossom.example.com'),
          'blossom.example.com',
        );
      });

      test('should remove http:// prefix', () {
        expect(formatBlossomUrl('http://localhost:8080'), 'localhost:8080');
      });

      test('should remove trailing slash', () {
        expect(
          formatBlossomUrl('https://blossom.example.com/'),
          'blossom.example.com',
        );
      });
    });

    group('normalizeBlossomUrl', () {
      test('should prepend https:// if no protocol is present', () {
        expect(
          normalizeBlossomUrl('blossom.example.com'),
          'https://blossom.example.com',
        );
      });

      test('should not prepend https:// if https:// is already present', () {
        expect(
          normalizeBlossomUrl('https://blossom.example.com'),
          'https://blossom.example.com',
        );
      });

      test('should not prepend https:// if http:// is already present', () {
        expect(
          normalizeBlossomUrl('http://localhost:8080'),
          'http://localhost:8080',
        );
      });

      test('should not prepend https:// if another protocol is present', () {
        expect(normalizeBlossomUrl('wss://relay.com'), 'wss://relay.com');
      });
    });

    group('isValidBlossomUrl', () {
      test('should return true for valid https:// urls', () {
        expect(isValidBlossomUrl('https://blossom.example.com'), isTrue);
      });

      test('should return true for valid http:// urls', () {
        expect(isValidBlossomUrl('http://localhost:8080'), isTrue);
      });

      test('should return false for wss:// urls', () {
        expect(isValidBlossomUrl('wss://relay.com'), isFalse);
      });

      test('should return false for malformed double protocol urls', () {
        expect(isValidBlossomUrl('https://https://example.com'), isFalse);
      });

      test('should return false for urls without protocol', () {
        expect(isValidBlossomUrl('blossom.example.com'), isFalse);
      });

      test('should return false for empty strings', () {
        expect(isValidBlossomUrl(''), isFalse);
      });

      test('should return false for hosts without dots (except localhost)', () {
        expect(isValidBlossomUrl('https://myserver'), isFalse);
        expect(isValidBlossomUrl('https://localhost'), isTrue);
      });
    });

    group('blossomBlobUrl', () {
      const sha256 =
          'b1674191a88ec5cdd733e4240a81803105dc412d6c6708d53ab94fc248f4f553';

      test('should append the extension of the mime type', () {
        expect(
          blossomBlobUrl('https://blossom.example.com', sha256, 'image/png'),
          'https://blossom.example.com/$sha256.png',
        );
      });

      test('should strip the trailing slash of the server', () {
        expect(
          blossomBlobUrl('https://blossom.example.com/', sha256, 'image/jpeg'),
          'https://blossom.example.com/$sha256.jpg',
        );
      });

      test('should leave the extension out for an unknown mime type', () {
        expect(
          blossomBlobUrl('https://blossom.example.com', sha256, 'image/x-nope'),
          'https://blossom.example.com/$sha256',
        );
      });
    });
  });
}
