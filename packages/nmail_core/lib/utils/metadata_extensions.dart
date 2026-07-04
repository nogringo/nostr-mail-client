import 'package:ndk/ndk.dart';

/// Returns the NIP-XX fallback name (anon_xxxxxxxx) from a hex pubkey.
String getAnonName(String pubkey) {
  if (pubkey.isEmpty) return 'Anonymous';
  try {
    final npub = Nip19.encodePubKey(pubkey);
    return 'anon_${npub.substring(5, 13)}';
  } catch (_) {}
  return 'Anonymous';
}

extension MetadataExtension on Metadata {
  /// The name the user actually set, or null if none.
  /// Priority: display_name > name > nip05 local part.
  String? get realName {
    if (displayName != null && displayName!.trim().isNotEmpty) {
      return displayName!.trim();
    }

    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }

    if (nip05 != null && nip05!.contains('@')) {
      final localPart = nip05!.split('@').first;
      if (localPart.isNotEmpty) {
        return localPart;
      }
    }

    return null;
  }

  /// Returns the best available name for a user according to NIP-XX.
  /// Priority: display_name > name > nip05 local part > anon_xxxxxxxx
  String getBestName() => realName ?? getAnonName(pubKey);
}
