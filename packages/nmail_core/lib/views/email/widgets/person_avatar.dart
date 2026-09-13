import 'package:flutter/material.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/widgets/email_avatar.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';

class PersonAvatar extends StatelessWidget {
  final EmailPerson person;
  final double radius;

  const PersonAvatar({super.key, required this.person, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final pubkey = person.pubkey;
    if (pubkey != null) return NostrAvatar(pubkey: pubkey, radius: radius);
    return EmailAvatar(mailAddress: person.address!, radius: radius);
  }
}
