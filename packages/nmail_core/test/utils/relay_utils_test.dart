import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/relay_utils.dart';

void main() {
  group('Relay Utils', () {
    group('formatRelayUrl', () {
      test('should remove wss:// prefix', () {
        expect(formatRelayUrl('wss://relay.damus.io'), 'relay.damus.io');
      });

      test('should remove ws:// prefix', () {
        expect(formatRelayUrl('ws://localhost:8080'), 'localhost:8080');
      });

      test('should handle url without prefix', () {
        expect(formatRelayUrl('relay.damus.io'), 'relay.damus.io');
      });
    });

    group('normalizeRelayUrl', () {
      test('should prepend wss:// if no protocol is present', () {
        expect(normalizeRelayUrl('relay.damus.io'), 'wss://relay.damus.io');
      });

      test('should not prepend wss:// if wss:// is already present', () {
        expect(
          normalizeRelayUrl('wss://relay.damus.io'),
          'wss://relay.damus.io',
        );
      });

      test('should not prepend wss:// if ws:// is already present', () {
        expect(normalizeRelayUrl('ws://localhost:8080'), 'ws://localhost:8080');
      });

      test('should not prepend wss:// if another protocol is present', () {
        expect(normalizeRelayUrl('http://relay.com'), 'http://relay.com');
        expect(normalizeRelayUrl('https://relay.com'), 'https://relay.com');
      });

      test('should not change malformed double protocol urls', () {
        expect(
          normalizeRelayUrl('ws://ws://example.com'),
          'ws://ws://example.com',
        );
      });

      test('should return empty string for empty input', () {
        expect(normalizeRelayUrl(''), '');
      });
    });

    group('isValidRelayUrl', () {
      test('should return true for valid wss:// urls', () {
        expect(isValidRelayUrl('wss://relay.damus.io'), isTrue);
      });

      test('should return true for valid ws:// urls', () {
        expect(isValidRelayUrl('ws://localhost:8080'), isTrue);
      });

      test('should return false for http:// urls', () {
        expect(isValidRelayUrl('http://relay.com'), isFalse);
      });

      test('should return false for https:// urls', () {
        expect(isValidRelayUrl('https://relay.com'), isFalse);
      });

      test('should return false for urls without protocol', () {
        expect(isValidRelayUrl('relay.damus.io'), isFalse);
      });

      test('should return false for malformed double protocol urls', () {
        expect(isValidRelayUrl('ws://ws://example.com'), isFalse);
      });

      test('should return false for empty strings', () {
        expect(isValidRelayUrl(''), isFalse);
      });

      test('should return false for urls with spaces', () {
        expect(isValidRelayUrl('wss://relay. damus.io'), isFalse);
      });

      test('should return false for invalid uri formats', () {
        expect(isValidRelayUrl('wss://'), isFalse);
      });
    });

    group('isLocalRelayUrl', () {
      test('should return true for loopback', () {
        expect(isLocalRelayUrl('ws://localhost:4869'), isTrue);
        expect(isLocalRelayUrl('ws://127.0.0.1:4869'), isTrue);
        expect(isLocalRelayUrl('ws://[::1]:4869'), isTrue);
      });

      test('should return true for private LAN ranges', () {
        expect(isLocalRelayUrl('ws://192.168.1.50:8080'), isTrue);
        expect(isLocalRelayUrl('ws://10.0.0.5:8080'), isTrue);
        expect(isLocalRelayUrl('ws://172.16.0.1:8080'), isTrue);
        expect(isLocalRelayUrl('ws://172.31.255.254:8080'), isTrue);
        expect(isLocalRelayUrl('ws://169.254.1.1:8080'), isTrue);
      });

      test('should return true for mDNS and bare hostnames', () {
        expect(isLocalRelayUrl('ws://nas.local:8080'), isTrue);
        expect(isLocalRelayUrl('ws://citrine:4869'), isTrue);
      });

      test('should return false for public relays', () {
        expect(isLocalRelayUrl('wss://relay.damus.io'), isFalse);
        expect(isLocalRelayUrl('wss://nos.lol'), isFalse);
        expect(isLocalRelayUrl('wss://8.8.8.8'), isFalse);
      });

      test('should not mistake a public host for a private range', () {
        expect(isLocalRelayUrl('wss://172.15.0.1'), isFalse);
        expect(isLocalRelayUrl('wss://172.32.0.1'), isFalse);
        expect(isLocalRelayUrl('wss://192.169.1.1'), isFalse);
        expect(isLocalRelayUrl('wss://fdns.example.com'), isFalse);
        expect(isLocalRelayUrl('wss://localhost.example.com'), isFalse);
      });

      test('should return false for unparseable input', () {
        expect(isLocalRelayUrl(''), isFalse);
        expect(isLocalRelayUrl('wss://'), isFalse);
      });
    });
  });
}
