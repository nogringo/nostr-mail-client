import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';

import '../models/recipient.dart';
import '../services/nostr_mail_service.dart';

class ComposeController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final isSending = false.obs;
  final recipients = <Recipient>[].obs;

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
    required String from,
    required String subject,
    required String body,
  }) async {
    if (recipients.isEmpty) return false;
    if (from.isEmpty) return false;

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
      final sentEmail = emails.where((e) => e.senderPubkey == myPubkey).firstOrNull;
      if (sentEmail != null) {
        return sentEmail.from;
      }

      // Fallback to received emails (use "to" which is my address)
      final receivedEmail = emails.where((e) => e.senderPubkey != myPubkey).firstOrNull;
      if (receivedEmail != null) {
        return receivedEmail.to;
      }
    } catch (_) {}

    return null;
  }
}
