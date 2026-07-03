import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:nmail_standard/views/email/email_controller.dart';
import 'package:nmail_standard/widgets/email_avatar.dart';
import 'package:nmail_standard/widgets/nostr_avatar.dart';

class MainRecipientAvatarView extends StatelessWidget {
  const MainRecipientAvatarView({super.key});

  @override
  Widget build(BuildContext context) {
    final email = EmailController.to.email!;
    // Direct nostr conversation: the recipient pubkey IS the contact.
    if (!email.isBridged) {
      return NostrAvatar(pubkey: email.recipientPubkey, radius: 12);
    }
    // Bridged: the legacy contact lives in the MIME To header.
    return EmailAvatar(
      mailAddress: email.mime.to?.firstOrNull ?? MailAddress(null, ''),
      radius: 12,
    );
  }
}
