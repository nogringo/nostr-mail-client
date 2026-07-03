import 'package:flutter/material.dart';
import 'package:nmail_standard/views/email/email_controller.dart';
import 'package:nmail_standard/widgets/nostr_avatar.dart';

class RecipientBridgeBadgeView extends StatelessWidget {
  const RecipientBridgeBadgeView({super.key});

  @override
  Widget build(BuildContext context) {
    return NostrAvatar(
      pubkey: EmailController.to.email!.recipientPubkey,
      radius: 7,
    );
  }
}
