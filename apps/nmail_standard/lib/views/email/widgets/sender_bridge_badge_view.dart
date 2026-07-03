import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:nmail_standard/widgets/nostr_avatar.dart';

class SenderBridgeBadgeView extends StatelessWidget {
  final Email email;

  const SenderBridgeBadgeView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return NostrAvatar(pubkey: email.senderPubkey, radius: 12);
  }
}
