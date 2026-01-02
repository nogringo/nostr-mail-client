enum RecipientType { nostr, legacy }

class Recipient {
  final String input;
  final String? pubkey;
  final String? displayName;
  final String? picture;
  final RecipientType type;
  final bool isLoading;

  const Recipient({
    required this.input,
    this.pubkey,
    this.displayName,
    this.picture,
    required this.type,
    this.isLoading = false,
  });

  Recipient copyWith({
    String? input,
    String? pubkey,
    String? displayName,
    String? picture,
    RecipientType? type,
    bool? isLoading,
  }) {
    return Recipient(
      input: input ?? this.input,
      pubkey: pubkey ?? this.pubkey,
      displayName: displayName ?? this.displayName,
      picture: picture ?? this.picture,
      type: type ?? this.type,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get label {
    if (type == RecipientType.nostr) {
      if (displayName != null && displayName!.isNotEmpty) {
        return displayName!;
      }
      if (pubkey != null && pubkey!.length > 16) {
        return 'npub1...${pubkey!.substring(pubkey!.length - 6)}';
      }
    }
    return input;
  }

  bool get isNostr => type == RecipientType.nostr;
  bool get isLegacy => type == RecipientType.legacy;
}
