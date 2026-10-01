import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart';

import '../../../controllers/inbox_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/utils/format_date.dart';

/// One email under its sender in requests, which the row above already names.
class RequestEmailRow extends GetView<InboxController> {
  final EmailSummary email;
  final VoidCallback onTap;

  const RequestEmailRow({super.key, required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isUnread = !controller.isEmailRead(email.id);
      return ListTile(
        // Lines the subject up with the sender's name above.
        leading: const SizedBox(width: 40),
        title: Text(
          email.subject.isEmpty ? l.emailNoSubject : email.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: isUnread ? FontWeight.w600 : null),
        ),
        subtitle: email.preview.isEmpty
            ? null
            : Text(email.preview, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(
          formatDate(context, email.date),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
      );
    });
  }
}
