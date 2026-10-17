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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FromOption &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => address.hashCode;
}
