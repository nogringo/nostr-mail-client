import 'dart:convert';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart' hide RelaySet;

import 'package:nmail_core/services/nostr_mail_service.dart';

class PrivateRelaysController extends ChangeNotifier {
  PrivateRelaysController() {
    loadData();
  }

  List<String>? originalPrivateRelays;
  List<String>? privateRelays;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool hasLoadFailed = false;
  bool isSaving = false;
  bool _isDisposed = false;

  bool get hasChanges {
    if (originalPrivateRelays == null || privateRelays == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalPrivateRelays!.length != privateRelays!.length) return true;
    for (final relay in originalPrivateRelays!) {
      if (!privateRelays!.contains(relay)) return true;
    }
    return false;
  }

  Future<void> loadData() async {
    try {
      final relays = await GetIt.I<NostrMailService>().getPrivateRelays();
      if (_isDisposed) return;
      originalPrivateRelays = List.from(relays);
      privateRelays = List.from(relays);
    } catch (_) {
      if (_isDisposed) return;
      hasLoadFailed = true;
    }
    isLoading = false;
    notifyListeners();
  }

  void addRelay(String relay) {
    if (privateRelays == null || privateRelays!.contains(relay)) return;
    privateRelays!.add(relay);
    notifyListeners();
  }

  void toggleRelayDeletion(String relayUrl) {
    if (markedForDeletion.contains(relayUrl)) {
      markedForDeletion.remove(relayUrl);
    } else {
      markedForDeletion.add(relayUrl);
    }
    notifyListeners();
  }

  void discardChanges() {
    if (originalPrivateRelays == null) return;
    privateRelays = List.from(originalPrivateRelays!);
    markedForDeletion.clear();
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    notifyListeners();
    try {
      final relaysToSave = privateRelays!
          .where((relay) => !markedForDeletion.contains(relay))
          .toList();

      final ndk = GetIt.I<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final plaintext = jsonEncode(
        relaysToSave.map((relay) => ['relay', relay]).toList(),
      );
      final unsigned = Nip01Event(
        pubKey: account.pubkey,
        kind: privateRelayListKind,
        tags: [],
        content: (await account.signer.encryptNip44(
          plaintext: plaintext,
          recipientPubKey: account.pubkey,
        ))!,
      );
      final signed = await account.signer.sign(unsigned);
      await ndk.config.cache.saveEvent(signed);
      // Reading back the version just written then never asks the signer.
      await ndk.decryptedEventPayloads.loadOrDecrypt(
        event: signed,
        viewerPubKey: account.pubkey,
        scheme: DecryptedPayloadScheme.nip44,
        decrypt: () async => plaintext,
      );
      await GetIt.I<OfflineBroadcast>().broadcast(
        signed,
        relaySet: RelaySet.outbox(account.pubkey),
        pubkey: account.pubkey,
      );
      if (_isDisposed) return;

      privateRelays = relaysToSave;
      originalPrivateRelays = List.from(relaysToSave);
      markedForDeletion.clear();
    } finally {
      if (!_isDisposed) {
        isSaving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
