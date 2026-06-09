import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../widgets/email_avatar.dart';
import '../../../widgets/nostr_avatar.dart';

class ContactAvatar extends StatelessWidget {
  final AddressBookContact contact;
  final double radius;

  const ContactAvatar({super.key, required this.contact, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final pubkey = contact.index.nostrIdentifiers
        .map(_pubkeyFromNostrUri)
        .whereType<String>()
        .firstOrNull;
    if (pubkey != null) {
      return NostrAvatar(pubkey: pubkey, radius: radius);
    }

    final email = contact.index.emails.isEmpty
        ? ''
        : contact.index.emails.first;
    return EmailAvatar(
      mailAddress: MailAddress(contact.index.formattedName, email),
      radius: radius,
    );
  }

  String? _pubkeyFromNostrUri(String uri) {
    if (!uri.toLowerCase().startsWith('nostr:')) return null;
    final value = uri.substring('nostr:'.length).replaceAll(RegExp(r'\s+'), '');
    try {
      if (value.startsWith('npub1')) return Nip19.decode(value);
      if (value.startsWith('nprofile1')) {
        return Nip19.decodeNprofile(value).pubkey;
      }
      if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(value)) {
        return value.toLowerCase();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
