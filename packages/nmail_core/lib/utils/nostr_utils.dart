import 'package:ndk/ndk.dart';

class NostrEventReference {
  final String eventId;
  final List<String> relays;

  const NostrEventReference({required this.eventId, this.relays = const []});
}

/// Extract pubkey from an address (npub1xxx@domain or hex@domain)
/// Returns null if parsing fails or address is legacy email
String? extractPubkeyFromAddress(String address) {
  if (!address.contains('@')) return null;

  final localPart = address.split('@').first;

  // Try npub format
  if (localPart.startsWith('npub1')) {
    try {
      return Nip19.decode(localPart);
    } catch (_) {
      return null;
    }
  }

  // Try hex format (64 chars)
  if (localPart.length == 64 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(localPart)) {
    return localPart.toLowerCase();
  }

  return null;
}

/// Extract the hex event id from a NIP-19 nevent, or null if it is not a
/// valid nevent. The nevent may also carry relay hints via [Nip19.decodeNevent].
String? eventIdFromNevent(String nevent) {
  return nostrEventReferenceFromString(nevent)?.eventId;
}

/// Decode an event reference accepted by Nmail routes and push payloads.
///
/// Hex and note references only carry the event id. A nevent also carries
/// relay hints, which are needed when opening emails that are not yet synced
/// into local storage.
NostrEventReference? nostrEventReferenceFromString(String reference) {
  if (reference.length == 64 && RegExp(r'^[a-fA-F0-9]+$').hasMatch(reference)) {
    return NostrEventReference(eventId: reference.toLowerCase());
  }

  if (reference.startsWith('nevent1')) {
    try {
      final nevent = Nip19.decodeNevent(reference);
      return NostrEventReference(
        eventId: nevent.eventId,
        relays: nevent.relays ?? const [],
      );
    } catch (_) {
      return null;
    }
  }

  if (reference.startsWith('note1')) {
    try {
      return NostrEventReference(eventId: Nip19.decode(reference));
    } catch (_) {
      return null;
    }
  }

  return null;
}
