import 'package:enough_mail_plus/enough_mail.dart';

import '../utils/metadata_extensions.dart';

enum RecipientType { nostr, legacy }

class Recipient {
  final String input;
  final String? pubkey;
  final String? displayName;
  final String? picture;
  final MailAddress? mailAddress;
  final RecipientType type;
  final bool isLoading;

  const Recipient({
    required this.input,
    this.pubkey,
    this.displayName,
    this.picture,
    this.mailAddress,
    required this.type,
    this.isLoading = false,
  });

  Recipient copyWith({
    String? input,
    String? pubkey,
    String? displayName,
    String? picture,
    MailAddress? mailAddress,
    RecipientType? type,
    bool? isLoading,
  }) {
    return Recipient(
      input: input ?? this.input,
      pubkey: pubkey ?? this.pubkey,
      displayName: displayName ?? this.displayName,
      picture: picture ?? this.picture,
      mailAddress: mailAddress ?? this.mailAddress,
      type: type ?? this.type,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get label {
    if (type == RecipientType.nostr) {
      if (displayName != null && displayName!.isNotEmpty) {
        return displayName!;
      }
      if (pubkey != null && pubkey!.isNotEmpty) {
        return getAnonName(pubkey!);
      }
    }
    if (mailAddress?.hasPersonalName == true) {
      return mailAddress!.personalName!;
    }
    if (mailAddress?.email.isNotEmpty == true) {
      return mailAddress!.email;
    }
    return input;
  }

  bool get isNostr => type == RecipientType.nostr;
  bool get isLegacy => type == RecipientType.legacy;
}
