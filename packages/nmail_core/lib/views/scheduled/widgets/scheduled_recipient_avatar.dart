import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/utils/scheduled_email_extensions.dart';
import 'package:nmail_core/views/email/widgets/person_avatar.dart';

/// Avatar of a scheduled email's recipient, matching the Sent list. A "+N"
/// badge marks additional recipients.
class ScheduledRecipientAvatar extends StatelessWidget {
  final ScheduledEmail email;
  final double radius;

  const ScheduledRecipientAvatar({
    super.key,
    required this.email,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = PersonAvatar(
      person: email.firstRecipientPerson,
      radius: radius,
    );

    final total = email.to.length + email.cc.length + email.bcc.length;
    final extra = total > 1 ? total - 1 : 0;
    if (extra == 0) return avatar;

    return Badge(
      label: Text('+$extra'),
      backgroundColor: colorScheme.primaryContainer,
      textColor: colorScheme.onPrimaryContainer,
      child: avatar,
    );
  }
}
