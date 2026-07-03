import 'package:enough_mail_plus/enough_mail.dart' as mail;
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:vcard_dart/vcard_dart.dart' as vcard;

import '../models/address_book_contact_form.dart';
import '../models/contact.dart';
import 'package:nmail_core/utils/contact_birthday_utils.dart';

class AddressBookVCardMapper {
  static final _parser = vcard.VCardParser(preserveRaw: true);
  static const _generator = vcard.VCardGenerator(
    productId: 'Nmail',
    foldLines: true,
  );

  static AddressBookContactForm formFromContact(AddressBookContact contact) {
    return _formFromParsed(
      _parser.parseSingle(contact.vCard),
      uid: contact.uid,
    );
  }

  /// Parses raw vCard text (one or many vCards) into contact forms.
  ///
  /// Used when importing a `.vcf` file that can contain several contacts.
  static List<AddressBookContactForm> formsFromVCardText(String text) {
    return _parser
        .parse(text)
        .map((parsed) => _formFromParsed(parsed, uid: parsed.uid))
        .toList();
  }

  static AddressBookContactForm _formFromParsed(
    vcard.VCard parsed, {
    String? uid,
  }) {
    return AddressBookContactForm(
      uid: uid,
      displayName: parsed.formattedName,
      emails: parsed.emails.map((email) => email.address).toList(),
      nostrPubkeys: _nostrPubkeys(parsed).toList(),
      phones: parsed.telephones.map((phone) => phone.number).toList(),
      birthday: _birthdayFromVCard(parsed.birthday),
    );
  }

  /// Merges an incoming (imported) contact into an existing one, taking the
  /// union of emails, phones, and Nostr identities (like a contacts merge).
  static AddressBookContactForm mergeForms(
    AddressBookContactForm base,
    AddressBookContactForm incoming,
  ) {
    return base.copyWith(
      displayName: base.displayName.trim().isNotEmpty
          ? base.displayName
          : incoming.displayName,
      emails: _unique([...base.emails, ...incoming.emails]),
      phones: _unique([...base.phones, ...incoming.phones]),
      nostrPubkeys: _unique([...base.nostrPubkeys, ...incoming.nostrPubkeys]),
      birthday: base.birthday ?? incoming.birthday,
    );
  }

  static String buildVCard(
    AddressBookContactForm form, {
    String? existingVCard,
  }) {
    final name = form.displayName.trim();
    final emails = _unique(form.emails.map((email) => email.trim()));
    final phones = _unique(form.phones.map((phone) => phone.trim()));
    final birthday = _parseBirthday(form.birthday);
    final nostrPubkeys = _unique(
      form.nostrPubkeys.map((pubkey) {
        final normalized = normalizeNostrPubkey(pubkey);
        if (normalized == null) {
          throw AddressBookValidationException('Invalid Nostr identifier');
        }
        return normalized;
      }),
    );

    if (name.isEmpty) {
      throw const AddressBookValidationException('Name is required');
    }
    for (final email in emails) {
      if (!_isValidEmail(email)) {
        throw AddressBookValidationException('Invalid email: $email');
      }
    }
    for (final phone in phones) {
      if (!_isValidPhone(phone)) {
        throw AddressBookValidationException('Invalid phone: $phone');
      }
    }

    final parsed = existingVCard == null || existingVCard.trim().isEmpty
        ? vcard.VCard(version: vcard.VCardVersion.v40)
        : _parser.parseSingle(existingVCard);

    parsed.version = vcard.VCardVersion.v40;
    parsed.uid = form.uid ?? parsed.uid;
    parsed.formattedName = name;
    parsed.name = vcard.StructuredName.raw(name);
    parsed.emails
      ..clear()
      ..addAll([
        for (var i = 0; i < emails.length; i++)
          vcard.Email(address: emails[i], pref: i == 0 ? 1 : null),
      ]);
    parsed.telephones
      ..clear()
      ..addAll([
        for (var i = 0; i < phones.length; i++)
          vcard.Telephone(number: phones[i], pref: i == 0 ? 1 : null),
      ]);
    parsed.birthday = birthday;

    final nonNostrImpps = parsed.impps
        .where((impp) => !impp.uri.toLowerCase().startsWith('nostr:'))
        .toList();
    parsed.impps
      ..clear()
      ..addAll(nonNostrImpps)
      ..addAll([
        for (var i = 0; i < nostrPubkeys.length; i++)
          vcard.InstantMessaging(
            uri: 'nostr:${Nip19.encodePubKey(nostrPubkeys[i])}',
            pref: i == 0 ? 1 : null,
          ),
      ]);

    return _generator.generate(parsed, version: vcard.VCardVersion.v40);
  }

  static List<Contact> suggestionsFromContact(AddressBookContact contact) {
    final name = contact.index.formattedName.trim().isNotEmpty
        ? contact.index.formattedName.trim()
        : null;
    return [
      for (final email in contact.index.emails)
        Contact(
          displayName: name,
          mailAddress: mail.MailAddress(name, email),
          source: ContactSource.addressBook,
          addressBookUid: contact.uid,
          contactMethodId: 'email:${email.toLowerCase()}',
        ),
      for (final pubkey
          in contact.index.nostrIdentifiers
              .map(_pubkeyFromNostrImpp)
              .whereType<String>())
        Contact(
          pubkey: pubkey,
          displayName: name,
          source: ContactSource.addressBook,
          addressBookUid: contact.uid,
          contactMethodId: 'nostr:$pubkey',
        ),
    ];
  }

  static String? normalizeNostrPubkey(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final value = trimmed.startsWith('nostr:')
        ? trimmed.substring('nostr:'.length)
        : trimmed;
    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value)) {
      return value.toLowerCase();
    }
    try {
      if (value.startsWith('nprofile1')) {
        return Nip19.decodeNprofile(value).pubkey;
      }
      if (value.startsWith('npub1')) {
        return Nip19.decode(value);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Iterable<String> _nostrPubkeys(vcard.VCard parsed) {
    return parsed.impps
        .map((impp) => _pubkeyFromNostrImpp(impp.uri))
        .whereType<String>();
  }

  static String? _pubkeyFromNostrImpp(String uri) {
    if (!uri.toLowerCase().startsWith('nostr:')) return null;
    return normalizeNostrPubkey(uri.substring('nostr:'.length));
  }

  static List<String> _unique(Iterable<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) result.add(trimmed);
    }
    return result;
  }

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  static bool _isValidPhone(String phone) {
    return RegExp(r'\d').hasMatch(phone) &&
        RegExp(r'^[0-9+().\-\s]+$').hasMatch(phone);
  }

  static ContactBirthday? _birthdayFromVCard(vcard.DateOrDateTime? birthday) {
    if (birthday == null || birthday.isEmpty) return null;
    final month = birthday.month;
    final day = birthday.day;
    // Keep only month+day(+year) birthdays; ignore day-only or partial values.
    if (month == null || day == null) return null;
    return ContactBirthday(year: birthday.year, month: month, day: day);
  }

  static vcard.DateOrDateTime? _parseBirthday(ContactBirthday? birthday) {
    if (birthday == null) return null;
    return vcard.DateOrDateTime.date(
      birthday.year,
      birthday.month,
      birthday.day,
    );
  }
}
