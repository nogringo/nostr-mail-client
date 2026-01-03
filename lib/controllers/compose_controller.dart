import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';

import '../models/from_option.dart';
import '../models/recipient.dart';
import '../services/nostr_mail_service.dart';
import 'auth_controller.dart';

const String _defaultBridgeDomain = 'uid.ovh';

class ComposeController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final isSending = false.obs;
  final recipients = <Recipient>[].obs;
  final Rxn<FromOption> selectedFrom = Rxn<FromOption>();
  final fromOptions = <FromOption>[].obs;

  Future<void> addRecipient(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return;

    // Check if already added
    if (recipients.any((r) => r.input == trimmed)) return;

    // Add with loading state
    final index = recipients.length;
    recipients.add(
      Recipient(input: trimmed, type: RecipientType.legacy, isLoading: true),
    );

    // Resolve recipient
    final resolved = await _resolveRecipient(trimmed);
    recipients[index] = resolved;
  }

  void removeRecipient(int index) {
    if (index >= 0 && index < recipients.length) {
      recipients.removeAt(index);
    }
  }

  Future<Recipient> _resolveRecipient(String input) async {
    // Check if npub
    if (input.startsWith('npub1')) {
      try {
        final pubkey = Nip19.decode(input);
        final metadata = await _fetchMetadata(pubkey);
        return Recipient(
          input: input,
          pubkey: pubkey,
          displayName: metadata?.name,
          picture: metadata?.picture,
          type: RecipientType.nostr,
        );
      } catch (_) {
        return Recipient(input: input, type: RecipientType.legacy);
      }
    }

    // Check if hex pubkey
    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(input)) {
      final pubkey = input.toLowerCase();
      final metadata = await _fetchMetadata(pubkey);
      return Recipient(
        input: input,
        pubkey: pubkey,
        displayName: metadata?.name,
        picture: metadata?.picture,
        type: RecipientType.nostr,
      );
    }

    // Check if email format - try NIP-05
    if (input.contains('@')) {
      try {
        final pubkey = await _resolveNip05(input);
        if (pubkey != null) {
          final metadata = await _fetchMetadata(pubkey);
          return Recipient(
            input: input,
            pubkey: pubkey,
            displayName: metadata?.name,
            picture: metadata?.picture,
            type: RecipientType.nostr,
          );
        }
      } catch (_) {}
    }

    // Fallback to legacy email
    return Recipient(input: input, type: RecipientType.legacy);
  }

  Future<String?> _resolveNip05(String identifier) async {
    final parts = identifier.split('@');
    if (parts.length != 2) return null;

    final name = parts[0];
    final domain = parts[1];
    final url = Uri.https(domain, '/.well-known/nostr.json', {'name': name});

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final names = json['names'] as Map<String, dynamic>?;
      if (names == null || !names.containsKey(name)) return null;

      return names[name] as String;
    } catch (_) {
      return null;
    }
  }

  Future<Metadata?> _fetchMetadata(String pubkey) async {
    try {
      return await _nostrMailService.ndk.metadata.loadMetadata(pubkey);
    } catch (_) {
      return null;
    }
  }

  Future<bool> send({
    String? from,
    required String subject,
    required String body,
  }) async {
    if (recipients.isEmpty) return false;

    isSending.value = true;
    try {
      for (final recipient in recipients) {
        await _nostrMailService.client.send(
          from: from,
          to: recipient.pubkey ?? recipient.input,
          subject: subject,
          body: body,
        );
      }
      return true;
    } catch (e) {
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<String?> getDefaultFrom() async {
    try {
      final myPubkey = _nostrMailService.getPublicKey();
      if (myPubkey == null) return null;

      final emails = await _nostrMailService.client.getEmails();

      // Check sent emails first
      final sentEmail = emails
          .where((e) => e.senderPubkey == myPubkey)
          .firstOrNull;
      if (sentEmail != null) {
        return sentEmail.from;
      }

      // Fallback to received emails (use "to" which is my address)
      final receivedEmail = emails
          .where((e) => e.senderPubkey != myPubkey)
          .firstOrNull;
      if (receivedEmail != null) {
        return receivedEmail.to;
      }
    } catch (_) {}

    return null;
  }

  /// Load all available From options
  Future<void> loadFromOptions() async {
    final options = <FromOption>[];
    final authController = Get.find<AuthController>();
    final npub = authController.npub;
    final metadata = authController.userMetadata.value;

    if (npub == null) return;

    // 1. Always add npub@nostr
    options.add(
      FromOption(
        address: '$npub@nostr',
        displayName: metadata?.name,
        picture: metadata?.picture,
        source: FromSource.npubNostr,
      ),
    );

    // 2. Always add npub@uid.ovh (default bridge)
    options.add(
      FromOption(
        address: '$npub@$_defaultBridgeDomain',
        displayName: metadata?.name,
        picture: metadata?.picture,
        source: FromSource.npubBridge,
      ),
    );

    // 3. Add npub@testnmail.uid.ovh (test bridge)
    options.add(
      FromOption(
        address: '$npub@testnmail.uid.ovh',
        displayName: metadata?.name,
        picture: metadata?.picture,
        source: FromSource.npubBridge,
      ),
    );

    // 4. Check if user's NIP-05 domain is a bridge
    final nip05 = metadata?.nip05;
    if (nip05 != null && nip05.contains('@')) {
      final domain = nip05.split('@').last;
      // Don't add if it's the default bridge domain (already added)
      if (domain != _defaultBridgeDomain) {
        final isBridge = await _isDomainBridge(domain);
        if (isBridge) {
          options.add(
            FromOption(
              address: nip05,
              displayName: metadata?.name,
              picture: metadata?.picture,
              source: FromSource.nip05Bridge,
            ),
          );
        }
      }
    }

    // 5. Scan emails for history
    final historyAddresses = await _getHistoryFromAddresses();
    for (final address in historyAddresses) {
      // Don't add duplicates
      if (!options.any((o) => o.address == address)) {
        options.add(FromOption(address: address, source: FromSource.history));
      }
    }

    fromOptions.value = options;

    // Set default selection
    if (selectedFrom.value == null && options.isNotEmpty) {
      await _selectDefaultFrom(options);
    }
  }

  Future<void> _selectDefaultFrom(List<FromOption> options) async {
    // Try to find last used From address
    final lastFrom = await getDefaultFrom();
    if (lastFrom != null) {
      final match = options.firstWhereOrNull((o) => o.address == lastFrom);
      if (match != null) {
        selectedFrom.value = match;
        return;
      }
    }

    // Fallback to npub@nostr
    selectedFrom.value = options.first;
  }

  /// Check if a domain is a bridge by looking up _smtp@domain
  Future<bool> _isDomainBridge(String domain) async {
    final url = Uri.https(domain, '/.well-known/nostr.json', {'name': '_smtp'});

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return false;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final names = json['names'] as Map<String, dynamic>?;

      // If _smtp exists and has a pubkey, it's a bridge
      return names != null && names.containsKey('_smtp');
    } catch (_) {
      return false;
    }
  }

  /// Get From addresses from email history
  Future<Set<String>> _getHistoryFromAddresses() async {
    final addresses = <String>{};

    try {
      final myPubkey = _nostrMailService.getPublicKey();
      if (myPubkey == null) return addresses;

      final emails = await _nostrMailService.client.getEmails();

      for (final email in emails) {
        // From sent emails: use the "from" field
        if (email.senderPubkey == myPubkey && email.from.isNotEmpty) {
          addresses.add(email.from);
        }
        // From received emails: use the "to" field (my address)
        if (email.senderPubkey != myPubkey && email.to.isNotEmpty) {
          addresses.add(email.to);
        }
      }
    } catch (_) {}

    return addresses;
  }

  void selectFrom(FromOption option) {
    selectedFrom.value = option;
  }
}
