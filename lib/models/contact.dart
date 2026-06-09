import 'package:enough_mail_plus/enough_mail.dart';
import 'package:ndk/ndk.dart';

import '../utils/metadata_extensions.dart';
import 'recipient.dart';

enum ContactSource {
  addressBook,
  emailHistory,
  nostrFollow,
  cachedProfile,
  nip05Lookup,
}

class Contact {
  final String? pubkey;
  final String? displayName;
  final String? picture;
  final String? nip05;
  final MailAddress? mailAddress;
  final ContactSource source;
  final DateTime? lastInteraction;
  final String? addressBookUid;
  final String? contactMethodId;

  const Contact({
    this.pubkey,
    this.displayName,
    this.picture,
    this.nip05,
    this.mailAddress,
    required this.source,
    this.lastInteraction,
    this.addressBookUid,
    this.contactMethodId,
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

  String get label {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (mailAddress?.hasPersonalName == true) {
      return mailAddress!.personalName!;
    }
    if (mailAddress?.email.isNotEmpty == true) {
      return mailAddress!.email;
    }
    if (pubkey != null && pubkey!.isNotEmpty) {
      return getAnonName(pubkey!);
    }
    return 'Unknown';
  }

  String? get subtitle {
    if (nip05 != null && nip05!.isNotEmpty && !_hasNpubLocalPart(nip05!)) {
      return nip05;
    }
    final email = mailAddress?.email;
    if (email != null && email.isNotEmpty && !_hasNpubLocalPart(email)) {
      return email;
    }
    return null;
  }

  bool _hasNpubLocalPart(String address) {
    if (!address.contains('@')) return false;
    return address.split('@').first.startsWith('npub1');
  }

  /// Unique identifier for this contact
  String get id =>
      contactMethodId ?? pubkey ?? mailAddress?.email.toLowerCase() ?? '';

  Recipient toRecipient() {
    if (isLegacy) {
      return Recipient(
        input: mailAddress?.email ?? '',
        mailAddress: mailAddress,
        type: RecipientType.legacy,
      );
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

    // Email match
    if (mailAddress?.email.isNotEmpty == true) {
      final e = mailAddress!.email.toLowerCase();
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
      if (source == ContactSource.addressBook) {
        score += 20;
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
