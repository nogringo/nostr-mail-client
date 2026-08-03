import 'package:ndk/entities.dart';

/// Outcome of a search for a user's NIP-65 relay list (kind 10002).
sealed class RelayListDiscoveryResult {
  const RelayListDiscoveryResult();
}

class RelayListFound extends RelayListDiscoveryResult {
  final Nip01Event event;
  final Map<String, ReadWriteMarker> relays;

  const RelayListFound({required this.event, required this.relays});
}

/// The relays answered and none of them has a kind 10002 for this pubkey.
class RelayListMissing extends RelayListDiscoveryResult {
  const RelayListMissing();
}

/// No relay could be reached, so the absence of a result means nothing.
class RelayListUnreachable extends RelayListDiscoveryResult {
  const RelayListUnreachable();
}
