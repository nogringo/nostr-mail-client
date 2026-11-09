import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/utils/relay_utils.dart';

void main() {
  group('needsPlainTransportWarning', () {
    test('plain ws to a public host warns', () {
      expect(needsPlainTransportWarning('ws://attacker.example'), isTrue);
      expect(needsPlainTransportWarning('ws://attacker.example:8080/ws'), isTrue);
    });

    test('local plaintext relays stay friction-free', () {
      expect(needsPlainTransportWarning('ws://localhost:8080'), isFalse);
      expect(needsPlainTransportWarning('ws://127.0.0.1:7777'), isFalse);
      expect(needsPlainTransportWarning('ws://strfry.local'), isFalse);
      expect(needsPlainTransportWarning('ws://192.168.1.10:7000'), isFalse);
    });

    test('encrypted transports never warn', () {
      expect(needsPlainTransportWarning('wss://relay.example'), isFalse);
      expect(needsPlainTransportWarning('wss://localhost'), isFalse);
    });
  });
}
