import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';

import '../models/contact.dart';
import 'nostr_mail_service.dart';

class ContactsService extends GetxService {
  final _nostrMailService = Get.find<NostrMailService>();
  final _ndk = Get.find<Ndk>();

  final contacts = <Contact>[].obs;
  final isLoading = false.obs;

  /// Load contacts from email history, Nostr follows, and NDK cache
  Future<void> loadContacts() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final allContacts = <String, Contact>{};
      final myPubkey = _nostrMailService.getPublicKey();

      // Load from email history first (highest priority)
      final historyContacts = await _loadEmailHistoryContacts();
      for (final contact in historyContacts) {
        allContacts[contact.id] = contact;
      }

      // Load from Nostr follows (second priority)
      final followContacts = await _loadNostrFollows();
      for (final contact in followContacts) {
        if (!allContacts.containsKey(contact.id)) {
          allContacts[contact.id] = contact;
        }
      }

      // Load from NDK cache (lowest priority, but broad coverage)
      final cachedContacts = await _loadCachedProfiles();
      for (final contact in cachedContacts) {
        // Skip own pubkey
        if (contact.pubkey == myPubkey) continue;
        if (!allContacts.containsKey(contact.id)) {
          allContacts[contact.id] = contact;
        }
      }

      contacts.value = allContacts.values.toList();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load contacts from email history (both Nostr and legacy)
  Future<List<Contact>> _loadEmailHistoryContacts() async {
    final List<Contact> result = [];

    try {
      if (!_nostrMailService.isClientInitialized) return result;

      final myPubkey = _nostrMailService.getPublicKey();
      if (myPubkey == null) return result;

      final emails = await _nostrMailService.client.getEmails();

      // Collect unique pubkeys from emails with their last interaction date
      final pubkeyDates = <String, DateTime>{};
      // Collect unique legacy emails
      final legacyEmailDates = <String, DateTime>{};

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
        if (isSentByMe && _isLegacyEmail(email.to)) {
          final legacyEmail = email.to.toLowerCase();
          final existing = legacyEmailDates[legacyEmail];
          if (existing == null || email.date.isAfter(existing)) {
            legacyEmailDates[legacyEmail] = email.date;
          }
        }
        // For received emails
        if (!isSentByMe && _isLegacyEmail(email.from)) {
          final legacyEmail = email.from.toLowerCase();
          final existing = legacyEmailDates[legacyEmail];
          if (existing == null || email.date.isAfter(existing)) {
            legacyEmailDates[legacyEmail] = email.date;
          }
        }
      }

      // Collect all pubkeys to load (from direct pubkeys and npub@ addresses)
      final allPubkeys = <String>{...pubkeyDates.keys};
      final npubEmailMap = <String, String>{}; // pubkey -> email address

      for (final entry in legacyEmailDates.entries) {
        final email = entry.key;
        final localPart = email.split('@').first;
        if (localPart.startsWith('npub1')) {
          try {
            final pubkey = Nip19.decode(localPart);
            if (!pubkeyDates.containsKey(pubkey)) {
              allPubkeys.add(pubkey);
              npubEmailMap[pubkey] = email;
            }
          } catch (_) {}
        }
      }

      // Batch load all metadata at once
      final metadataMap = <String, Metadata>{};
      if (allPubkeys.isNotEmpty) {
        try {
          final metadatas = await _ndk.metadata.loadMetadatas(
            allPubkeys.toList(),
            null,
          );
          for (final m in metadatas) {
            metadataMap[m.pubKey] = m;
          }
        } catch (_) {}
      }

      // Add Nostr contacts from pubkeyDates
      for (final entry in pubkeyDates.entries) {
        final metadata = metadataMap[entry.key];
        result.add(
          Contact(
            pubkey: entry.key,
            displayName: metadata?.name,
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
        final lastInteraction = legacyEmailDates[email];
        result.add(
          Contact(
            pubkey: pubkey,
            displayName: metadata?.name,
            picture: metadata?.picture,
            nip05: metadata?.nip05 ?? email,
            source: ContactSource.emailHistory,
            lastInteraction: lastInteraction,
          ),
        );
      }

      // Add regular legacy email contacts (non-npub)
      for (final entry in legacyEmailDates.entries) {
        final email = entry.key;
        final localPart = email.split('@').first;
        // Skip npub@ addresses (already handled above)
        if (!localPart.startsWith('npub1')) {
          result.add(
            Contact(
              legacyEmail: email,
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
      final metadataMap = <String, Metadata>{};
      try {
        final metadatas = await _ndk.metadata.loadMetadatas(
          followPubkeys.toList(),
          null,
        );
        for (final m in metadatas) {
          metadataMap[m.pubKey] = m;
        }
      } catch (_) {}

      // Create contacts with loaded metadata
      for (final pubkey in followPubkeys) {
        final metadata = metadataMap[pubkey];
        result.add(
          Contact(
            pubkey: pubkey,
            displayName: metadata?.name,
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
      // Exclude already added recipients (check both pubkey and legacyEmail)
      if (excludeIds != null) {
        if (contact.pubkey != null && excludeIds.contains(contact.pubkey)) {
          return false;
        }
        if (contact.legacyEmail != null &&
            excludeIds.contains(contact.legacyEmail!.toLowerCase())) {
          return false;
        }
      }

      // Exclude "npub only" contacts - must have displayName, nip05, or legacyEmail
      final hasDisplayName = contact.displayName?.isNotEmpty == true;
      final hasNip05 = contact.nip05?.isNotEmpty == true;
      final hasLegacyEmail = contact.legacyEmail?.isNotEmpty == true;
      if (!hasDisplayName && !hasNip05 && !hasLegacyEmail) {
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
        metadata = await _ndk.metadata.loadMetadata(pubkey);
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
