import 'package:enough_mail_plus/enough_mail.dart';
import 'package:nostr_mail/nostr_mail.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/utils/nostr_utils.dart';

extension DraftX on Draft {
  /// First To, else Cc, else Bcc. Null while the draft has none.
  EmailPerson? get firstRecipientPerson {
    final address = to.firstOrNull ?? cc.firstOrNull ?? bcc.firstOrNull;
    if (address == null) return null;
    final pubkey = extractPubkeyFromAddress(address);
    return pubkey != null
        ? EmailPerson.nostr(pubkey)
        : EmailPerson.email(MailAddress(null, address));
  }

  int get recipientCount => to.length + cc.length + bcc.length;
}
