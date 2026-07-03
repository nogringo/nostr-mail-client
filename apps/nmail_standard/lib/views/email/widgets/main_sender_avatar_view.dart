import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_standard/widgets/email_avatar.dart';
import 'package:nmail_standard/widgets/nostr_avatar.dart';

class MainSenderAvatarView extends StatelessWidget {
  final Email email;

  const MainSenderAvatarView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    // Direct nostr conversation: the sender pubkey IS the contact.
    if (!email.isBridged) {
      return NostrAvatar(pubkey: email.senderPubkey, radius: 24);
    }
    // Bridged: the legacy contact lives in the MIME From header.
    return EmailAvatar(
      mailAddress: email.sender ?? MailAddress(null, ''),
      radius: 24,
    );
  }
}
