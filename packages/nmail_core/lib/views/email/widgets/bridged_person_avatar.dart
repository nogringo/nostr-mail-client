import 'package:flutter/material.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/widgets/nostr_avatar.dart';
import 'person_avatar.dart';

/// [person]'s avatar, badged with the bridge that relayed their email when
/// there is one.
class BridgedPersonAvatar extends StatelessWidget {
  final EmailPerson person;
  final double radius;

  const BridgedPersonAvatar({
    super.key,
    required this.person,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = PersonAvatar(person: person, radius: radius);
    final bridgePubkey = person.bridgePubkey;
    if (bridgePubkey == null || bridgePubkey.isEmpty) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
            child: NostrAvatar(pubkey: bridgePubkey, radius: radius / 2),
          ),
        ),
      ],
    );
  }
}
