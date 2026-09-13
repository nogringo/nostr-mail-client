import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/email_person_utils.dart';

import 'person_avatar.dart';
import 'person_bridge_label.dart';

class PersonCardMenuHeader extends StatelessWidget {
  final EmailPerson person;

  const PersonCardMenuHeader({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final identifier = emailPersonIdentifier(person);
    final bridgePubkey = person.bridgePubkey;
    final showIdentifier =
        person.pubkey != null || emailPersonName(person) != identifier;
    final nameStyle = textTheme.titleSmall;
    final name = person.pubkey == null
        ? Text(emailPersonName(person), style: nameStyle)
        : Obx(
            () => Text(
              emailPersonName(person),
              style: nameStyle,
              overflow: TextOverflow.ellipsis,
            ),
          );

    return Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          PersonAvatar(person: person, radius: 20),
          const SizedBox(width: 12),
          Flexible(
            child: DefaultTextStyle.merge(
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  name,
                  if (showIdentifier) ...[
                    const SizedBox(height: 2),
                    person.pubkey == null
                        ? Text(identifier)
                        : Text(identifier, overflow: TextOverflow.ellipsis),
                  ],
                  if (bridgePubkey != null) ...[
                    const SizedBox(height: 4),
                    PersonBridgeLabel(bridgePubkey: bridgePubkey),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
