import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:enough_mail_plus/enough_mail.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';

import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/utils/metadata_extensions.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class ContactsService extends GetxService {
  final _nostrMailService = Get.find<NostrMailService>();
  final _ndk = Get.find<Ndk>();
  AddressBookService? get _addressBookService =>
      Get.isRegistered<AddressBookService>()
      ? Get.find<AddressBookService>()
      : null;

  final contacts = <Contact>[].obs;
  final isLoading = false.obs;

  /// Load contacts from email history, Nostr follows, and NDK cache
  Future<void> loadContacts() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final allContacts = <String, Contact>{};
      final myPubkey = _nostrMailService.getPublicKey();

      // Load saved address-book contacts first (highest priority)
      await _addressBookService?.load(sync: false);
      for (final contact in _addressBookService?.suggestionContacts() ?? []) {
        allContacts[contact.id] = contact;
      }

      // Load from email history next
      final historyContacts = await _loadEmailHistoryContacts();
      for (final contact in historyContacts) {
        _putIfNoDuplicate(allContacts, contact);
      }

      // Load from Nostr follows (second priority)
      final followContacts = await _loadNostrFollows();
      for (final contact in followContacts) {
        _putIfNoDuplicate(allContacts, contact);
      }

      // Load from NDK cache (lowest priority, but broad coverage)
      final cachedContacts = await _loadCachedProfiles();
      for (final contact in cachedContacts) {
        // Skip own pubkey
        if (contact.pubkey == myPubkey) continue;
        _putIfNoDuplicate(allContacts, contact);
      }

      contacts.value = allContacts.values.toList();
    } finally {
      isLoading.value = false;
    }
  }

  void _putIfNoDuplicate(Map<String, Contact> contacts, Contact contact) {
    final pubkey = contact.pubkey;
    final email = contact.mailAddress?.email.toLowerCase();
    final duplicate = contacts.values.any((existing) {
      if (pubkey != null && existing.pubkey == pubkey) return true;
      if (email != null && existing.mailAddress?.email.toLowerCase() == email) {
        return true;
      }
      return false;
    });
    if (!duplicate) {
      contacts[contact.id] = contact;
    }
  }

  /// Load contacts from email history (both Nostr and legacy)
  Future<List<Contact>> _loadEmailHistoryContacts() async {
    final List<Contact> result = [];

    try {
      final myPubkey = _nostrMailService.getPublicKey();
      if (myPubkey == null) return result;

      final emails = await _nostrMailService.client.getEmails();

      // Collect unique pubkeys from emails with their last interaction date
      final pubkeyDates = <String, DateTime>{};
      // Collect unique legacy emails
      final legacyEmailDates = <MailAddress, DateTime>{};

      for (final email in emails) {
        final isSentByMe = email.senderPubkey == myPubkey;

        // Handle Nostr contacts (with pubkey)
        final otherPubkey = isSentByMe
            ? email.recipientPubkey
            : email.senderPubkey;
        if (otherPubkey.isNotEmpty && otherPubkey != myPubkey) {
          final existing = pubkeyDates[otherPubkey];
          if (existing == null || email.date.isAfter(existing)) {
            pubkeyDates[otherPubkey] = email.date;
          }
        }

        // Handle legacy emails - addresses NOT ending with @nostr
        // For sent emails
        if (isSentByMe) {
          final toAddr = email.mime.to?.firstOrNull;
          if (toAddr != null && _isLegacyEmail(toAddr.email)) {
            final legacyEmail = toAddr.email.toLowerCase();
            final existingEntry = legacyEmailDates.entries.firstWhereOrNull(
              (e) => e.key.email.toLowerCase() == legacyEmail,
            );
            if (existingEntry == null ||
                email.date.isAfter(existingEntry.value)) {
              legacyEmailDates[toAddr] = email.date;
            }
          }
        }
        // For received emails
        if (!isSentByMe) {
          final fromAddr = email.sender;
          if (fromAddr != null && _isLegacyEmail(fromAddr.email)) {
            final legacyEmail = fromAddr.email.toLowerCase();
            final existingEntry = legacyEmailDates.entries.firstWhereOrNull(
              (e) => e.key.email.toLowerCase() == legacyEmail,
            );
            if (existingEntry == null ||
                email.date.isAfter(existingEntry.value)) {
              legacyEmailDates[fromAddr] = email.date;
            }
          }
        }
      }

      // Collect all pubkeys to load (from direct pubkeys and npub@ addresses)
      final allPubkeys = <String>{...pubkeyDates.keys};
      final npubEmailMap = <String, String>{}; // pubkey -> email address

      for (final entry in legacyEmailDates.entries) {
        final mailAddr = entry.key;
        final localPart = mailAddr.email.split('@').first;
        if (localPart.startsWith('npub1')) {
          try {
            final pubkey = Nip19.decode(localPart);
            if (!pubkeyDates.containsKey(pubkey)) {
              allPubkeys.add(pubkey);
              npubEmailMap[pubkey] = mailAddr.email;
            }
          } catch (_) {}
        }
      }

      // Batch load all metadata at once
      final metadataMap = allPubkeys.isEmpty
          ? const <String, Metadata>{}
          : await Get.find<MetadataService>().loadMany(allPubkeys.toList());

      // Add Nostr contacts from pubkeyDates
      for (final entry in pubkeyDates.entries) {
        final metadata = metadataMap[entry.key];
        result.add(
          Contact(
            pubkey: entry.key,
            displayName: metadata?.getBestName(),
            picture: metadata?.picture,
            nip05: metadata?.nip05,
            source: ContactSource.emailHistory,
            lastInteraction: entry.value,
          ),
        );
      }

      // Add contacts from npub@ addresses
      for (final entry in npubEmailMap.entries) {
        final pubkey = entry.key;
        final email = entry.value;
        final metadata = metadataMap[pubkey];
        final mailAddr = legacyEmailDates.entries
            .firstWhereOrNull(
              (e) => e.key.email.toLowerCase() == email.toLowerCase(),
            )
            ?.key;
        final lastInteraction = mailAddr != null
            ? legacyEmailDates[mailAddr]
            : null;
        result.add(
          Contact(
            pubkey: pubkey,
            displayName: metadata?.getBestName(),
            picture: metadata?.picture,
            nip05: metadata?.nip05 ?? email,
            source: ContactSource.emailHistory,
            lastInteraction: lastInteraction,
          ),
        );
      }

      // Add regular legacy email contacts (non-npub)
      for (final entry in legacyEmailDates.entries) {
        final mailAddr = entry.key;
        final localPart = mailAddr.email.split('@').first;
        // Skip npub@ addresses (already handled above)
        if (!localPart.startsWith('npub1')) {
          result.add(
            Contact(
              mailAddress: mailAddr,
              source: ContactSource.emailHistory,
              lastInteraction: entry.value,
            ),
          );
        }
      }
    } catch (_) {}

    return result;
  }

  /// Check if an address is a legacy email (not a Nostr address)
  /// Nostr addresses end with @nostr, legacy emails don't
  bool _isLegacyEmail(String address) {
    if (address.isEmpty) return false;
    if (!address.contains('@')) return false;
    // Nostr addresses end with @nostr
    if (address.toLowerCase().endsWith('@nostr')) return false;
    return true;
  }

  /// Load contacts from Nostr follows (kind 3)
  Future<List<Contact>> _loadNostrFollows() async {
    final List<Contact> result = [];

    try {
      final myPubkey = _nostrMailService.getPublicKey();
      if (myPubkey == null) return result;

      // Load contact list (kind 3) from cache
      final contactList = await _ndk.follows.getContactList(myPubkey);
      if (contactList == null) return result;

      final followPubkeys = contactList.contacts;
      if (followPubkeys.isEmpty) return result;

      // Batch load all metadata at once
      final metadataMap = await Get.find<MetadataService>().loadMany(
        followPubkeys.toList(),
      );

      // Create contacts with loaded metadata
      for (final pubkey in followPubkeys) {
        final metadata = metadataMap[pubkey];
        result.add(
          Contact(
            pubkey: pubkey,
            displayName: metadata?.getBestName(),
            picture: metadata?.picture,
            nip05: metadata?.nip05,
            source: ContactSource.nostrFollow,
          ),
        );
      }
    } catch (_) {}

    return result;
  }

  /// Load all profiles from NDK cache (kind 0)
  Future<List<Contact>> _loadCachedProfiles() async {
    final List<Contact> result = [];

    try {
      // Load all metadata events (kind 0) from cache
      final events = await _ndk.config.cache.loadEvents(
        kinds: [Metadata.kKind],
      );

      for (final event in events) {
        try {
          final metadata = Metadata.fromEvent(event);
          // Only add if has a displayable name or nip05
          if ((metadata.name != null && metadata.name!.isNotEmpty) ||
              (metadata.nip05 != null && metadata.nip05!.isNotEmpty)) {
            result.add(
              Contact(
                pubkey: metadata.pubKey,
                displayName: metadata.name,
                picture: metadata.picture,
                nip05: metadata.nip05,
                source: ContactSource.cachedProfile,
              ),
            );
          }
        } catch (_) {}
      }
    } catch (_) {}

    return result;
  }

  /// Search contacts by query (sync, local only)
  List<Contact> search(String query, {Set<String>? excludeIds}) {
    if (query.isEmpty) return [];

    final q = query.toLowerCase().trim();
    if (q.length < 2) return [];

    final filtered = contacts.where((contact) {
      // Exclude already added recipients (check both pubkey and email)
      if (excludeIds != null) {
        if (contact.pubkey != null && excludeIds.contains(contact.pubkey)) {
          return false;
        }
        if (contact.mailAddress?.email.isNotEmpty == true &&
            excludeIds.contains(contact.mailAddress!.email.toLowerCase())) {
          return false;
        }
      }

      // Exclude "npub only" contacts - must have displayName, nip05, or email
      final hasDisplayName = contact.displayName?.isNotEmpty == true;
      final hasNip05 = contact.nip05?.isNotEmpty == true;
      final hasEmail = contact.mailAddress?.email.isNotEmpty == true;
      if (!hasDisplayName && !hasNip05 && !hasEmail) {
        return false;
      }

      return contact.matchScore(q) > 0;
    }).toList();

    // Sort by match score (descending)
    filtered.sort((a, b) => b.matchScore(q).compareTo(a.matchScore(q)));

    // Limit results
    return filtered.take(10).toList();
  }

  /// Search contacts with NIP-05 resolution
  Future<List<Contact>> searchAsync(
    String query, {
    Set<String>? excludeIds,
  }) async {
    if (query.isEmpty) return [];

    final q = query.trim();
    if (q.length < 2) return [];

    // Start with local results
    final results = search(query, excludeIds: excludeIds);

    // If query looks like a NIP-05, try to resolve it
    if (q.contains('@')) {
      final nip05Contact = await _resolveNip05(q);
      if (nip05Contact != null) {
        // Check if not already in results or excluded
        final isDuplicate = results.any((c) => c.pubkey == nip05Contact.pubkey);
        final isExcluded = excludeIds?.contains(nip05Contact.pubkey) ?? false;
        if (!isDuplicate && !isExcluded) {
          // Insert at the beginning
          results.insert(0, nip05Contact);
        }
      }
    }

    return results;
  }

  /// Resolve a NIP-05 identifier to a Contact
  Future<Contact?> _resolveNip05(String identifier) async {
    try {
      final parts = identifier.split('@');
      if (parts.length != 2) return null;

      final name = parts[0];
      final domain = parts[1];
      if (name.isEmpty || domain.isEmpty) return null;

      final url = Uri.https(domain, '/.well-known/nostr.json', {'name': name});
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final names = json['names'] as Map<String, dynamic>?;
      if (names == null || !names.containsKey(name)) return null;

      final pubkey = names[name] as String;
      if (pubkey.isEmpty) return null;

      // Fetch metadata for this pubkey
      Metadata? metadata;
      try {
        metadata = await Get.find<MetadataService>().load(pubkey);
      } catch (_) {}

      return Contact(
        pubkey: pubkey,
        displayName: metadata?.name,
        picture: metadata?.picture,
        nip05: identifier,
        source: ContactSource.nip05Lookup,
      );
    } catch (_) {
      return null;
    }
  }
}
