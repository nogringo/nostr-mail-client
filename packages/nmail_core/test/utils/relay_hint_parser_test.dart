import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/utils/relay_hint_parser.dart';

void main() {
  group('parseRelayHint', () {
    group('relay urls', () {
      test('accepts a wss url as typed', () {
        final result = parseRelayHint('wss://relay.damus.io');
        expect(result.hint!.kind, RelayHintKind.relay);
        expect(result.hint!.value, 'wss://relay.damus.io');
        expect(result.hint!.relays, ['wss://relay.damus.io']);
      });

      test('accepts a ws url', () {
        final result = parseRelayHint('ws://localhost:8080');
        expect(result.hint!.kind, RelayHintKind.relay);
        expect(result.hint!.relays, ['ws://localhost:8080']);
      });

      test('normalizes a bare host to wss', () {
        final result = parseRelayHint('purplepag.es');
        expect(result.hint!.kind, RelayHintKind.relay);
        expect(result.hint!.value, 'wss://purplepag.es');
      });

      test('trims surrounding whitespace', () {
        final result = parseRelayHint('  wss://nos.lol  ');
        expect(result.hint!.value, 'wss://nos.lol');
      });
    });

    group('nip05 identifiers', () {
      test('accepts name@domain', () {
        final result = parseRelayHint('alice@example.com');
        expect(result.hint!.kind, RelayHintKind.nip05);
        expect(result.hint!.value, 'alice@example.com');
        expect(result.hint!.relays, isEmpty);
      });

      test('lowercases the identifier', () {
        final result = parseRelayHint('Alice@Example.COM');
        expect(result.hint!.value, 'alice@example.com');
      });

      test('accepts a subdomain', () {
        final result = parseRelayHint('bob@mail.example.co.uk');
        expect(result.hint!.kind, RelayHintKind.nip05);
      });

      test('rejects a domain without a dot', () {
        expect(parseRelayHint('alice@localhost').error, isNotNull);
      });
    });

    group('nprofile', () {
      test('extracts the embedded relays', () {
        final nprofile = Nip19.encodeNprofile(
          pubkey: 'a' * 64,
          relays: ['wss://relay.damus.io', 'wss://nos.lol'],
        );
        final result = parseRelayHint(nprofile);
        expect(result.hint!.kind, RelayHintKind.nprofile);
        expect(result.hint!.relays, [
          'wss://relay.damus.io',
          'wss://nos.lol',
        ]);
      });

      test('rejects an nprofile carrying no relay', () {
        final nprofile = Nip19.encodeNprofile(pubkey: 'a' * 64, relays: []);
        expect(
          parseRelayHint(nprofile).error,
          RelayHintError.npubWithoutRelays,
        );
      });

      test('rejects a malformed nprofile', () {
        expect(parseRelayHint('nprofile1notbech32').error, isNotNull);
      });
    });

    group('rejections', () {
      test('rejects an empty input', () {
        expect(parseRelayHint('   ').error, RelayHintError.empty);
      });

      test('rejects an npub, which carries no relay', () {
        final npub = Nip19.encodePubKey('a' * 64);
        expect(parseRelayHint(npub).error, RelayHintError.npubWithoutRelays);
      });

      test('rejects free text', () {
        expect(parseRelayHint('where is my list').error, isNotNull);
      });
    });

    test('strips a nostr: scheme', () {
      final npub = Nip19.encodePubKey('a' * 64);
      expect(
        parseRelayHint('nostr:$npub').error,
        RelayHintError.npubWithoutRelays,
      );
    });
  });
}
