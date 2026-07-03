import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';
import 'metadata_extensions.dart';

/// Standardized Nostr avatar color palette (NIP-XX).
/// Each entry contains the background color and its associated text color for optimal contrast.
class NostrAvatarColor {
  final Color background;
  final Color text;

  const NostrAvatarColor(this.background, this.text);
}

/// 20-color palette derived from Tailwind CSS.
const nostrAvatarPalette = [
  NostrAvatarColor(Color(0xFF7C3AED), Colors.white), // 0: Purple (Nostr)
  NostrAvatarColor(Color(0xFF6366F1), Colors.white), // 1: Indigo
  NostrAvatarColor(Color(0xFF3B82F6), Colors.white), // 2: Blue
  NostrAvatarColor(Color(0xFF0EA5E9), Colors.white), // 3: Sky
  NostrAvatarColor(Color(0xFF06B6D4), Colors.black87), // 4: Cyan
  NostrAvatarColor(Color(0xFF14B8A6), Colors.black87), // 5: Teal
  NostrAvatarColor(Color(0xFF10B981), Colors.black87), // 6: Emerald
  NostrAvatarColor(Color(0xFF22C55E), Colors.black87), // 7: Green
  NostrAvatarColor(Color(0xFF84CC16), Colors.black87), // 8: Lime
  NostrAvatarColor(Color(0xFFEAB308), Colors.black87), // 9: Yellow
  NostrAvatarColor(Color(0xFFF59E0B), Colors.black87), // 10: Amber
  NostrAvatarColor(Color(0xFFF97316), Colors.black87), // 11: Orange
  NostrAvatarColor(Color(0xFFEF4444), Colors.black87), // 12: Red
  NostrAvatarColor(Color(0xFFEC4899), Colors.black87), // 13: Pink
  NostrAvatarColor(Color(0xFFD946EF), Colors.black87), // 14: Fuchsia
  NostrAvatarColor(Color(0xFFA855F7), Colors.black87), // 15: Violet
  NostrAvatarColor(Color(0xFF8B5CF6), Colors.black87), // 16: Light Purple
  NostrAvatarColor(Color(0xFF6366F1), Colors.white), // 17: Periwinkle
  NostrAvatarColor(Color(0xFF06B6D4), Colors.black87), // 18: Aqua
  NostrAvatarColor(Color(0xFF14B8A6), Colors.black87), // 19: Mint
];

/// Derives an avatar color from a pubkey using the NIP default picture algorithm.
/// Extracts 6 hex characters from the middle (indices 29-34), parses as integer,
/// and computes modulo to select from the standardized palette.
NostrAvatarColor getAvatarColorFromPubkey(String pubkey) {
  final normalizedPubkey = pubkey.toLowerCase();
  final hexChars = normalizedPubkey.substring(29, 35);
  final value = int.parse(hexChars, radix: 16);
  final index = value % nostrAvatarPalette.length;
  return nostrAvatarPalette[index];
}

/// Derives a single initial from metadata or pubkey fallback.
String getInitialFromMetadata(String pubkey, Metadata? metadata) {
  final name = metadata?.realName;
  if (name != null && name.isNotEmpty) {
    return name[0].toUpperCase();
  }

  // Fallback: pubkey character at index 28 → letter A-P
  final normalizedPubkey = pubkey.toLowerCase();
  final hexChar = normalizedPubkey[28];
  final value = int.parse(hexChar, radix: 16);
  return String.fromCharCode(65 + value); // 'A' + value (0-15 → A-P)
}
