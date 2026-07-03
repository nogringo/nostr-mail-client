import 'package:enough_mail_plus/enough_mail.dart';

enum FromSource {
  npubNostr, // npub@nostr (always available)
  npubBridge, // npub@uid.ovh (default bridge)
  nip05Bridge, // nip05@domain (if domain is a bridge)
  customIdentity, // user-created custom identity
}

class FromOption {
  final MailAddress mailAddress;
  final String? picture;
  final FromSource source;

  const FromOption({
    required this.mailAddress,
    this.picture,
    required this.source,
  });

  String get address => mailAddress.email;
  String? get displayName => mailAddress.personalName;

  String get label {
    if (displayName?.isNotEmpty ?? false) {
      return displayName!;
    }
    return shortAddress;
  }

  /// Returns a shortened address with domain visible (except @nostr)
  String get shortAddress {
    final parts = mailAddress.email.split('@');
    if (parts.length != 2) return mailAddress.email;

    final localPart = parts[0];
    final domain = parts[1];

    // Hide @nostr (only for compatibility)
    if (domain == 'nostr') {
      if (localPart.startsWith('npub1') && localPart.length > 16) {
        return 'npub1...${localPart.substring(localPart.length - 4)}';
      }
      return localPart;
    }

    // Shorten npub addresses but show domain
    if (localPart.startsWith('npub1') && localPart.length > 16) {
      return 'npub1...${localPart.substring(localPart.length - 4)}@$domain';
    }

    return address;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FromOption &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}
