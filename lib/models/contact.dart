import 'package:ndk/ndk.dart';

import 'recipient.dart';

enum ContactSource { emailHistory, nostrFollow, cachedProfile, nip05Lookup }

class Contact {
  final String? pubkey;
  final String? displayName;
  final String? picture;
  final String? nip05;
  final String? legacyEmail;
  final ContactSource source;
  final DateTime? lastInteraction;

  const Contact({
    this.pubkey,
    this.displayName,
    this.picture,
    this.nip05,
    this.legacyEmail,
    required this.source,
    this.lastInteraction,
  });

  bool get isLegacy => pubkey == null || pubkey!.isEmpty;

  String? get npub {
    if (pubkey == null || pubkey!.isEmpty) return null;
    try {
      return Nip19.encodePubKey(pubkey!);
    } catch (_) {
      return pubkey;
    }
  }

  String? get shortNpub {
    final n = npub;
    if (n == null) return null;
    if (n.length > 16) {
      return 'npub1...${n.substring(n.length - 6)}';
    }
    return n;
  }

  String get label {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (legacyEmail != null && legacyEmail!.isNotEmpty) {
      return legacyEmail!;
    }
    return shortNpub ?? 'Unknown';
  }

  String get subtitle {
    if (nip05 != null && nip05!.isNotEmpty) {
      return _formatNip05(nip05!);
    }
    if (legacyEmail != null && legacyEmail!.isNotEmpty) {
      return legacyEmail!;
    }
    return shortNpub ?? '';
  }

  /// Format nip05 for display - shorten npub if present
  String _formatNip05(String nip05) {
    if (!nip05.contains('@')) return nip05;

    final parts = nip05.split('@');
    final localPart = parts.first;
    final domain = parts.last;

    // If local part is an npub, shorten it
    if (localPart.startsWith('npub1') && localPart.length > 20) {
      final short = 'npub1...${localPart.substring(localPart.length - 6)}';
      return '$short@$domain';
    }

    return nip05;
  }

  /// Unique identifier for this contact
  String get id => pubkey ?? legacyEmail ?? '';

  Recipient toRecipient() {
    if (isLegacy) {
      return Recipient(input: legacyEmail ?? '', type: RecipientType.legacy);
    }
    return Recipient(
      input: npub ?? pubkey!,
      pubkey: pubkey,
      displayName: displayName,
      picture: picture,
      type: RecipientType.nostr,
    );
  }

  /// Calculate match score for search query (higher = better match)
  int matchScore(String query) {
    final q = query.toLowerCase();
    int score = 0;

    // Name match (highest priority)
    if (displayName != null) {
      final name = displayName!.toLowerCase();
      if (name == q) {
        score += 100;
      } else if (name.startsWith(q)) {
        score += 80;
      } else if (name.contains(q)) {
        score += 50;
      }
    }

    // NIP-05 match
    if (nip05 != null) {
      final n = nip05!.toLowerCase();
      if (n.startsWith(q)) {
        score += 70;
      } else if (n.contains(q)) {
        score += 40;
      }
    }

    // Legacy email match
    if (legacyEmail != null) {
      final e = legacyEmail!.toLowerCase();
      if (e.startsWith(q)) {
        score += 60;
      } else if (e.contains(q)) {
        score += 35;
      }
    }

    // npub match
    if (npub != null) {
      final n = npub!.toLowerCase();
      if (n.startsWith(q)) {
        score += 30;
      } else if (n.contains(q)) {
        score += 15;
      }
    }

    // pubkey hex match
    if (pubkey != null) {
      final hex = pubkey!.toLowerCase();
      if (hex.startsWith(q)) {
        score += 20;
      } else if (hex.contains(q)) {
        score += 10;
      }
    }

    // Only add boosts if there's already a text match
    if (score > 0) {
      // Boost score for email history contacts
      if (source == ContactSource.emailHistory) {
        score += 5;
      }

      // Boost for recent interactions
      if (lastInteraction != null) {
        final daysAgo = DateTime.now().difference(lastInteraction!).inDays;
        if (daysAgo < 7) {
          score += 10;
        } else if (daysAgo < 30) {
          score += 5;
        }
      }
    }

    return score;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
