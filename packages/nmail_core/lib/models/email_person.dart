import 'package:enough_mail_plus/enough_mail.dart';

/// Someone named in an email header: a Nostr identity or an email address.
class EmailPerson {
  final String? pubkey;
  final MailAddress? address;

  /// The bridge that relayed [address], when the email came through one.
  final String? bridgePubkey;

  const EmailPerson.nostr(String this.pubkey)
    : address = null,
      bridgePubkey = null;

  const EmailPerson.email(MailAddress this.address, {this.bridgePubkey})
    : pubkey = null;
}
