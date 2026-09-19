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

typedef PersonCardActionsBuilder =
    List<PersonCardAction> Function(
      BuildContext actionContext,
      AddressBookContact? contact,
    );

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
    buildContactAction(context, contact, () => _contactForm(person)),
    buildCopyAction(
      context,
      label: person.pubkey != null ? l.inboxCopyNpub : l.personCardCopyEmail,
      text: emailPersonIdentifier(person),
    ),
  ];
}

PersonCardAction buildContactAction(
  BuildContext context,
  AddressBookContact? contact,
  AddressBookContactForm Function() newContactForm,
) {
  final l = AppLocalizations.of(context);
  if (contact != null) {
    return PersonCardAction(
      icon: Icons.person_outline,
      label: l.personCardViewContact,
      onPressed: () => _openContact(context, contact),
    );
  }
  return PersonCardAction(
    icon: Icons.person_add_alt_1_outlined,
    label: l.contactsAddToContacts,
    onPressed: () => showContactForm(context, initialForm: newContactForm()),
  );
}

PersonCardAction buildCopyAction(
  BuildContext context, {
  required String label,
  required String text,
}) {
  return PersonCardAction(
    icon: Icons.copy_outlined,
    label: label,
    onPressed: () {
      Clipboard.setData(ClipboardData(text: text));
      showContactCopyFeedback(context, AppLocalizations.of(context).authCopied);
    },
  );
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

AddressBookContactForm _contactForm(EmailPerson person) {
  final pubkey = person.pubkey;
  final email = person.address?.email;
  return AddressBookContactForm(
    displayName: emailPersonName(person),
    emails: email == null || email.isEmpty ? const [] : [email],
    nostrPubkeys: pubkey == null ? const [] : [pubkey],
  );
}
