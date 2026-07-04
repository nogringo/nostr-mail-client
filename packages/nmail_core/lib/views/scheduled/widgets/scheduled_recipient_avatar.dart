import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/utils/nostr_utils.dart';
import 'package:nmail_core/utils/scheduled_email_extensions.dart';
import '../../../widgets/email_avatar.dart';
import '../../../widgets/nostr_avatar.dart';

/// Avatar of a scheduled email's recipient, matching the Sent list: a nostr
/// profile avatar when the recipient is a nostr identity, else a coloured
/// initial. A "+N" badge marks additional recipients.
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
    final first = email.firstRecipient;
    final pubkey = extractPubkeyFromAddress(first) ?? '';

    final avatar = pubkey.isNotEmpty
        ? NostrAvatar(pubkey: pubkey, radius: radius)
        : EmailAvatar(mailAddress: MailAddress(null, first), radius: radius);

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
