import 'package:enough_mail_plus/enough_mail.dart' show MailAddress;
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:nostr_mail/nostr_mail.dart' show EmailSummary;

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';

/// The name the user gave the contact wins over the one the person gives
/// themselves. A call inside `Obx` follows contact edits and profile updates.
String emailPersonName(EmailPerson person) {
  final contactName = emailPersonContact(person)?.index.formattedName.trim();
  if (contactName != null && contactName.isNotEmpty) return contactName;

  final pubkey = person.pubkey;
  if (pubkey != null) {
    final metadata = Get.find<MetadataService>().of(pubkey).value;
    return metadata?.getBestName() ?? getAnonName(pubkey);
  }
  final address = person.address!;
  final personalName = address.personalName?.trim();
  return personalName == null || personalName.isEmpty
      ? address.email
      : personalName;
}

/// Who sent [email]. A bridged email names its sender in the MIME From, the
/// gift wrap only the bridge.
EmailPerson summarySender(EmailSummary email) => email.isBridged
    ? EmailPerson.email(
        MailAddress(email.fromName, email.from),
        bridgePubkey: email.senderPubkey,
      )
    : EmailPerson.nostr(email.senderPubkey);

/// The npub for a Nostr identity, the address otherwise.
String emailPersonIdentifier(EmailPerson person) {
  final pubkey = person.pubkey;
  return pubkey != null ? Nip19.encodePubKey(pubkey) : person.address!.email;
}

/// Always reads the address book, so a call inside `Obx` follows contact
/// edits.
AddressBookContact? emailPersonContact(EmailPerson person) =>
    findEmailPersonContact(Get.find<AddressBookService>().contacts(), person);

AddressBookContact? findEmailPersonContact(
  Iterable<AddressBookContact> contacts,
  EmailPerson person,
) {
  final pubkey = person.pubkey;
  if (pubkey != null) {
    return contacts
        .where(
          (contact) => contact.index.nostrIdentifiers.any(
            (id) => AddressBookVCardMapper.normalizeNostrPubkey(id) == pubkey,
          ),
        )
        .firstOrNull;
  }
  final email = person.address!.email.trim().toLowerCase();
  if (email.isEmpty) return null;
  return contacts
      .where(
        (contact) => contact.index.emails.any(
          (candidate) => candidate.trim().toLowerCase() == email,
        ),
      )
      .firstOrNull;
}
