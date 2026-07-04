import 'package:flutter/material.dart';
import 'package:nmail_core/views/email/email_controller.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

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
