import 'package:ndk/ndk.dart';

import 'package:nmail_core/utils/relay_utils.dart';

enum RelayHintKind {
  /// A relay URL to search directly.
  relay,

  /// A NIP-05 identifier whose `.well-known/nostr.json` may name relays.
  nip05,

  /// A NIP-19 nprofile, which embeds relay hints.
  nprofile,
}

enum RelayHintError {
  empty,

  /// An npub carries no relay, so it cannot help locate anything.
  npubWithoutRelays,

  malformed,
}

/// A hint about where to look for a relay list, parsed from free text.
///
/// [value] is the normalized form: a `wss://` URL, a lowercased NIP-05
/// identifier, or the nprofile as typed.
class RelayHint {
  final RelayHintKind kind;
  final String value;

  /// Relays carried by the hint itself, already known without any lookup.
  final List<String> relays;

  const RelayHint({
    required this.kind,
    required this.value,
    this.relays = const [],
  });
}

class RelayHintParseResult {
  final RelayHint? hint;
  final RelayHintError? error;

  const RelayHintParseResult.success(this.hint) : error = null;
  const RelayHintParseResult.failure(this.error) : hint = null;
}

final _nip05Pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

RelayHintParseResult parseRelayHint(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return const RelayHintParseResult.failure(RelayHintError.empty);
  }

  final withoutScheme = trimmed.replaceFirst(RegExp('^nostr:'), '');

  if (withoutScheme.startsWith('npub1')) {
    return const RelayHintParseResult.failure(RelayHintError.npubWithoutRelays);
  }

  if (withoutScheme.startsWith('nprofile1')) {
    try {
      final nprofile = Nip19.decodeNprofile(withoutScheme);
      final relays = nprofile.relays ?? const <String>[];
      if (relays.isEmpty) {
        return const RelayHintParseResult.failure(
          RelayHintError.npubWithoutRelays,
        );
      }
      return RelayHintParseResult.success(
        RelayHint(
          kind: RelayHintKind.nprofile,
          value: withoutScheme,
          relays: relays.map(normalizeRelayUrl).toList(),
        ),
      );
    } catch (_) {
      return const RelayHintParseResult.failure(RelayHintError.malformed);
    }
  }

  if (_nip05Pattern.hasMatch(trimmed)) {
    return RelayHintParseResult.success(
      RelayHint(kind: RelayHintKind.nip05, value: trimmed.toLowerCase()),
    );
  }

  // An '@' means a NIP-05 was intended; as a relay URL it would be read as
  // userinfo, which no relay uses.
  if (trimmed.contains('@')) {
    return const RelayHintParseResult.failure(RelayHintError.malformed);
  }

  final normalized = normalizeRelayUrl(trimmed);
  if (isValidRelayUrl(normalized)) {
    return RelayHintParseResult.success(
      RelayHint(
        kind: RelayHintKind.relay,
        value: normalized,
        relays: [normalized],
      ),
    );
  }

  return const RelayHintParseResult.failure(RelayHintError.malformed);
}
