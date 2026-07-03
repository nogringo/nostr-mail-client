import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nmail_standard/controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_standard/utils/format_date_time.dart';
import 'package:nmail_standard/views/contacts/widgets/show_contact_form.dart';
import 'package:nmail_standard/views/email/email_controller.dart';
import 'package:nmail_standard/views/email/widgets/sender_avatar_view.dart';

import 'recipients_list_view.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final controller = EmailController.to;
    final email = controller.email;
    if (email == null) return const SizedBox.shrink();

    final to = email.mime.to ?? [];
    final cc = email.mime.cc ?? [];
    final bcc = email.mime.bcc ?? [];
    final recipientCount = to.length + cc.length + bcc.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (email.subject?.isEmpty ?? true) ? l.emailNoSubject : email.subject!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SenderAvatarView(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.senderDisplayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        formatDateTime(context, email.date),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          controller.showRecipients =
                              !controller.showRecipients;
                          controller.update();
                        },
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.showRecipients
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$recipientCount',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        tooltip: l.emailShowRecipients,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              tooltip: l.contactsAddToContacts,
              onPressed: () => _addSenderToContacts(context, controller),
            ),
          ],
        ),
        if (controller.showRecipients) ...[
          const SizedBox(height: 12),
          const RecipientsListView(),
        ],
      ],
    );
  }

  void _addSenderToContacts(BuildContext context, EmailController controller) {
    if (!Get.isRegistered<ContactsController>()) {
      Get.put(ContactsController());
    }
    final email = controller.email!;
    final mailAddress = email.sender;
    final isDirectNostr = !email.isBridged;
    showContactForm(
      context,
      initialForm: AddressBookContactForm(
        displayName: controller.senderDisplayName,
        emails: !isDirectNostr && mailAddress?.email.isNotEmpty == true
            ? [mailAddress!.email]
            : const [],
        nostrPubkeys: isDirectNostr ? [email.senderPubkey] : const [],
      ),
    );
  }
}
