import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'package:nmail_core/controllers/compose_controller.dart';
import 'package:nmail_core/controllers/recipient_autocomplete_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/models/recipient.dart';
import 'package:nmail_core/utils/email_person_utils.dart';
import 'package:nmail_core/utils/toast_helper.dart';
import 'package:nmail_core/views/email/widgets/person_card_actions.dart';

import 'recipient_autocomplete.dart';

final _keyInput = RegExp(r'^(npub1|nprofile1|naddr1)|^[0-9a-fA-F]{64}$');

EmailPerson recipientPerson(Recipient recipient) {
  final pubkey = recipient.pubkey;
  if (pubkey != null) return EmailPerson.nostr(pubkey);
  return EmailPerson.email(
    recipient.mailAddress ?? MailAddress(null, recipient.input),
  );
}

/// [context] must outlive the card: the actions run after it closes.
List<PersonCardAction> buildRecipientChipActions(
  BuildContext context,
  AddressBookContact? contact, {
  required RecipientField field,
  required Recipient recipient,
}) {
  final l = AppLocalizations.of(context);
  final controller = ComposeController.to;
  final pubkey = recipient.pubkey;
  final smtpAddress = recipient.smtpAddress;
  final fieldLabels = {
    RecipientField.to: l.composeTo,
    RecipientField.cc: l.composeCc,
    RecipientField.bcc: l.composeBcc,
  };

  return [
    if (recipient.isNostr && smtpAddress != null)
      PersonCardAction(
        icon: Icons.swap_horiz,
        label: l.composeRecipientSendViaSmtp,
        onPressed: () => controller.sendViaSmtp(field, recipient),
      ),
    if (recipient.isLegacy)
      PersonCardAction(
        icon: Icons.swap_horiz,
        label: l.composeRecipientSendViaNostr,
        onPressed: () => _sendViaNostr(context, field, recipient),
      ),
    if (!_keyInput.hasMatch(recipient.input))
      PersonCardAction(
        icon: Icons.edit_outlined,
        label: l.composeRecipientEdit,
        onPressed: () => _edit(field, recipient),
      ),
    for (final target in RecipientField.values)
      if (target != field)
        PersonCardAction(
          icon: target.index > field.index ? Icons.move_down : Icons.move_up,
          label: l.composeRecipientMoveTo(fieldLabels[target]!),
          onPressed: () => controller.moveRecipient(recipient, field, target),
        ),
    buildContactAction(
      context,
      contact,
      () => AddressBookContactForm(
        displayName: emailPersonName(recipientPerson(recipient)),
        emails: smtpAddress == null ? const [] : [smtpAddress],
        nostrPubkeys: pubkey == null ? const [] : [pubkey],
      ),
    ),
    if (pubkey != null)
      buildCopyAction(
        context,
        label: l.inboxCopyNpub,
        text: Nip19.encodePubKey(pubkey),
      ),
    if (smtpAddress != null)
      buildCopyAction(context, label: l.personCardCopyEmail, text: smtpAddress),
    PersonCardAction(
      icon: Icons.close,
      label: l.actionRemove,
      onPressed: () => controller.removeRecipientFrom(field, recipient),
    ),
  ];
}

Future<void> _sendViaNostr(
  BuildContext context,
  RecipientField field,
  Recipient recipient,
) async {
  final result = await ComposeController.to.sendViaNostr(field, recipient);
  if (!context.mounted) return;
  final l = AppLocalizations.of(context);
  switch (result) {
    case NostrLookupResult.found:
      return;
    case NostrLookupResult.notFound:
      ToastHelper.error(
        context,
        l.composeRecipientNostrNotFound(recipient.input),
      );
    case NostrLookupResult.unreachable:
      ToastHelper.error(
        context,
        l.composeRecipientNostrUnreachable(recipient.input.split('@').last),
      );
  }
}

void _edit(RecipientField field, Recipient recipient) {
  final controller = ComposeController.to;
  controller.editRecipient(field, recipient);
  final tag = RecipientAutocomplete.tagFor(controller.textControllerOf(field));
  // After the menu closes, or it takes the focus back.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!Get.isRegistered<RecipientAutocompleteController>(tag: tag)) return;
    Get.find<RecipientAutocompleteController>(
      tag: tag,
    ).focusNode.requestFocus();
  });
}
