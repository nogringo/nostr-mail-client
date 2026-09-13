import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'package:nmail_core/models/email_person.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';

/// Reads the metadata store, so a call inside `Obx` follows profile updates.
String emailPersonName(EmailPerson person) {
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

/// The npub for a Nostr identity, the address otherwise.
String emailPersonIdentifier(EmailPerson person) {
  final pubkey = person.pubkey;
  return pubkey != null ? Nip19.encodePubKey(pubkey) : person.address!.email;
}

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
