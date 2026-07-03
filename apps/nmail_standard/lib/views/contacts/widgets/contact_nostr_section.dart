import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../../../controllers/contacts_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../widgets/nostr_avatar.dart';
import 'contact_action_row.dart';
import 'contact_section_title.dart';
import 'nostr_identity_label.dart';

class ContactNostrSection extends StatelessWidget {
  final AddressBookContact contact;

  const ContactNostrSection({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = Get.find<ContactsController>();
    final pubkeys = contact.index.nostrIdentifiers
        .map(_pubkeyFromNostrUri)
        .whereType<String>()
        .toList();
    if (pubkeys.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContactSectionTitle(l.contactsNostrTitle),
        const SizedBox(height: 8),
        for (final pubkey in pubkeys)
          ContactActionRow(
            icon: Icons.key,
            title: NostrIdentityName(identifier: pubkey),
            leading: NostrAvatar(pubkey: pubkey, radius: 16),
            copyValue: Nip19.encodePubKey(pubkey),
            onCompose: () => controller.composeToPubkey(context, pubkey),
          ),
      ],
    );
  }
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
