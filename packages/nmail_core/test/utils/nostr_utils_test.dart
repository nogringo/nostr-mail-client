import 'package:flutter_test/flutter_test.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/utils/nostr_utils.dart';

void main() {
  group('nostrEventReferenceFromString', () {
    const eventId =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

    test('accepts hex event ids', () {
      final reference = nostrEventReferenceFromString(eventId.toUpperCase());

      expect(reference?.eventId, eventId);
      expect(reference?.relays, isEmpty);
    });

    test('accepts note ids', () {
      final note = Nip19.encodeNoteId(eventId);

      final reference = nostrEventReferenceFromString(note);

      expect(reference?.eventId, eventId);
      expect(reference?.relays, isEmpty);
    });

    test('preserves nevent relay hints', () {
      final nevent = Nip19.encodeNevent(
        eventId: eventId,
        relays: const ['wss://relay.example', 'wss://relay2.example'],
        kind: 1059,
      );

      final reference = nostrEventReferenceFromString(nevent);

      expect(reference?.eventId, eventId);
      expect(reference?.relays, const [
        'wss://relay.example',
        'wss://relay2.example',
      ]);
    });

    test('rejects invalid references', () {
      expect(nostrEventReferenceFromString('not-an-event'), isNull);
    });
  });

  group('shortenNpub', () {
    test('keeps the first ten and last six characters', () {
      final npub = Nip19.encodePubKey(
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
      );

      final shortened = shortenNpub(npub);

      expect(
        shortened,
        '${npub.substring(0, 10)}...${npub.substring(npub.length - 6)}',
      );
      expect(shortened.length, 19);
    });

    test('leaves short values untouched', () {
      expect(shortenNpub('npub1short'), 'npub1short');
      expect(shortenNpub(''), '');
    });
  });
}
