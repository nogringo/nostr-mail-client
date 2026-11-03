import 'package:flutter_test/flutter_test.dart';
import 'package:nmail_core/app/auth_consent.dart';

void main() {
  const defaults = {'wss://default.relay', 'https://default.blossom'};
  final defaultsNormalised = defaults.map((u) => u.toLowerCase()).toSet();

  AuthConsent consent({
    OwnHostLists? own,
    Object? thrower,
  }) {
    return AuthConsent(
      loadOwnLists: (pubkey) async {
        if (thrower != null) throw thrower;
        return own;
      },
      defaults: defaults,
    );
  }

  group('allow', () {
    test('default hosts are allowed without loading anything', () async {
      var loads = 0;
      final c = AuthConsent(
        loadOwnLists: (_) async {
          loads++;
          return null;
        },
        defaults: defaults,
      );
      expect(await c('wss://default.relay', 'pk'), isTrue);
      expect(await c('https://DEFAULT.blossom/', 'pk'), isTrue);
      expect(loads, 0, reason: 'defaults must not need the own-list fetch');
    });

    test('unknown hosts are denied', () async {
      final c = consent(own: (relays: {}, servers: {}));
      expect(await c('wss://attacker.example', 'pk'), isFalse);
      expect(await c('https://evil.blossom.example', 'pk'), isFalse);
    });

    test('a hostile relay from someone else\\'s list stays anonymous', () async {
      final c = consent(
        own: (
          relays: {'wss://own.relay'},
          servers: {'https://own.blossom'},
        ),
      );
      expect(await c('wss://own.relay', 'pk'), isTrue);
      // A recipient's 10050 or a fetched discovery result is not ours.
      expect(await c('wss://recipient-dm.relay.example', 'pk'), isFalse);
    });

    test('own Blossom servers from 10063 are allowed', () async {
      final c = consent(
        own: (relays: {}, servers: {'https://own.blossom'}),
      );
      expect(await c('https://own.blossom/blob.png', 'pk'), isTrue);
    });

    test('trailing slashes and case do not bypass the check', () async {
      final c = consent(
        own: (relays: {'wss://own.relay'}, servers: {}),
      );
      expect(await c('wss://OWN.relay///', 'pk'), isTrue);
      expect(await c('wss://not-own.relay/', 'pk'), isFalse);
    });

    test('a different pubkey invalidates the cache', () async {
      var calls = 0;
      final c = AuthConsent(
        loadOwnLists: (pubkey) async {
          calls++;
          return pubkey == 'pk-a'
              ? (relays: {'wss://a.relay'}, servers: <String>{})
              : (relays: {'wss://b.relay'}, servers: <String>{});
        },
        defaults: const {},
      );
      expect(await c('wss://a.relay', 'pk-a'), isTrue);
      expect(await c('wss://b.relay', 'pk-b'), isTrue);
      expect(await c('wss://a.relay', 'pk-a'), isFalse);
      expect(calls, 2);
    });

    test('list load failure fails closed to defaults', () async {
      final c = consent(thrower: StateError('offline'));
      expect(await c('wss://default.relay', 'pk'), isTrue);
      expect(await c('wss://own.relay', 'pk'), isFalse);
    });

    test('a load triggered by a nested auth question does not recurse',
        () async {
      late AuthConsent c;
      c = AuthConsent(
        loadOwnLists: (_) async {
          // Simulates the fetch hitting a challenging relay: the handler is
          // re-entered while loading.
          final nested = await c('wss://random.relay.example', 'pk');
          expect(nested, isFalse,
              reason: 'in-flight questions must be denied, not recursed');
          return (relays: {'wss://own.relay'}, servers: <String>{});
        },
        defaults: defaults,
      );
      expect(await c('wss://own.relay', 'pk'), isTrue);
    });
  });
}
