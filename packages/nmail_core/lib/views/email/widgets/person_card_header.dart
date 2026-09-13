import 'package:flutter/material.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

import 'person_avatar.dart';
import 'person_bridge_label.dart';
import 'person_name.dart';

class PersonCardHeader extends StatelessWidget {
  final EmailPerson person;

  const PersonCardHeader({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final identifier = emailPersonIdentifier(person);
    final bridgePubkey = person.bridgePubkey;
    final showIdentifier =
        person.pubkey != null || emailPersonName(person) != identifier;

    return ListTile(
      leading: PersonAvatar(person: person, radius: 24),
      title: PersonName(person: person),
      subtitle: showIdentifier || bridgePubkey != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIdentifier)
                  person.pubkey == null
                      ? Text(identifier)
                      : Text(
                          identifier,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                if (bridgePubkey != null) ...[
                  const SizedBox(height: 4),
                  PersonBridgeLabel(bridgePubkey: bridgePubkey),
                ],
              ],
            )
          : null,
    );
  }
}
