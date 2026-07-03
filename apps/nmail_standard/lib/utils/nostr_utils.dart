import 'package:ndk/ndk.dart';

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
