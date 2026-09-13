import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'package:nmail_core/app/routes/app_routes.dart';
import 'package:nmail_core/controllers/contacts_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/responsive_helper.dart';
import 'package:nmail_core/views/contacts/widgets/contact_copy_feedback.dart';
import 'package:nmail_core/views/contacts/widgets/mobile_contact_detail_page.dart';
import 'package:nmail_core/views/contacts/widgets/show_contact_form.dart';

class PersonCardAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const PersonCardAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

/// [context] must outlive the card: the actions run after it closes.
List<PersonCardAction> buildPersonCardActions(
  BuildContext context,
  EmailPerson person,
  AddressBookContact? contact,
) {
  final l = AppLocalizations.of(context);
  return [
    PersonCardAction(
      icon: Icons.edit_outlined,
      label: l.personCardCompose,
      onPressed: () => _compose(context, person),
    ),
    if (contact != null)
      PersonCardAction(
        icon: Icons.person_outline,
        label: l.personCardViewContact,
        onPressed: () => _openContact(context, contact),
      )
    else
      PersonCardAction(
        icon: Icons.person_add_alt_1_outlined,
        label: l.contactsAddToContacts,
        onPressed: () => _addContact(context, person),
      ),
    PersonCardAction(
      icon: Icons.copy_outlined,
      label: person.pubkey != null ? l.inboxCopyNpub : l.personCardCopyEmail,
      onPressed: () => _copyIdentifier(context, person),
    ),
  ];
}

void _compose(BuildContext context, EmailPerson person) {
  final pubkey = person.pubkey;
  final recipient = pubkey != null
      ? Recipient(
          input: emailPersonIdentifier(person),
          pubkey: pubkey,
          type: RecipientType.nostr,
        )
      : Recipient(input: person.address!.email, type: RecipientType.legacy);
  context.push(AppRoutes.compose, extra: {'recipient': recipient});
}

void _openContact(BuildContext context, AddressBookContact contact) {
  if (!Get.isRegistered<ContactsController>()) {
    Get.put(ContactsController());
  }
  if (ResponsiveHelper.isNotMobile(context)) {
    Get.find<ContactsController>()
      ..queryController.clear()
      ..select(contact);
    context.go(AppRoutes.contacts);
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MobileContactDetailPage(uid: contact.uid),
    ),
  );
}

void _addContact(BuildContext context, EmailPerson person) {
  final pubkey = person.pubkey;
  final email = person.address?.email;
  showContactForm(
    context,
    initialForm: AddressBookContactForm(
      displayName: emailPersonName(person),
      emails: email == null || email.isEmpty ? const [] : [email],
      nostrPubkeys: pubkey == null ? const [] : [pubkey],
    ),
  );
}

void _copyIdentifier(BuildContext context, EmailPerson person) {
  Clipboard.setData(ClipboardData(text: emailPersonIdentifier(person)));
  showContactCopyFeedback(context, AppLocalizations.of(context).authCopied);
}
