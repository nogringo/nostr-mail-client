import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/utils/draft_extensions.dart';
import 'package:nmail_core/views/email/widgets/person_avatar.dart';

/// Avatar of a draft's first recipient, matching the Sent list. A "+N" badge
/// marks additional recipients.
class DraftRecipientAvatar extends StatelessWidget {
  final Draft draft;
  final double radius;

  const DraftRecipientAvatar({
    super.key,
    required this.draft,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final person = draft.firstRecipientPerson;
    if (person == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.insert_drive_file_outlined,
          size: radius,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final avatar = PersonAvatar(person: person, radius: radius);
    final extra = draft.recipientCount - 1;
    if (extra <= 0) return avatar;

    return Badge(
      label: Text('+$extra'),
      backgroundColor: colorScheme.primaryContainer,
      textColor: colorScheme.onPrimaryContainer,
      child: avatar,
    );
  }
}
