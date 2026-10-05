import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart' hide RelaySet;

import 'package:nmail_core/services/nostr_mail_service.dart';

class DmRelaysController extends ChangeNotifier {
  DmRelaysController() {
    loadData();
  }

  List<String>? originalDmRelays;
  List<String>? dmRelays;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;
  bool _isDisposed = false;

  bool get hasChanges {
    if (originalDmRelays == null || dmRelays == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalDmRelays!.length != dmRelays!.length) return true;
    for (final relay in originalDmRelays!) {
      if (!dmRelays!.contains(relay)) return true;
    }
    return false;
  }

  Future<void> loadData() async {
    final nostrMailService = GetIt.I<NostrMailService>();
    final relays = await nostrMailService.getDmRelays();
    if (_isDisposed) return;

    originalDmRelays = List.from(relays);
    dmRelays = List.from(relays);
    isLoading = false;
    notifyListeners();
  }

  void addRelay(String relay) {
    if (dmRelays == null || dmRelays!.contains(relay)) return;
    dmRelays!.add(relay);
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
    if (originalDmRelays == null) return;
    dmRelays = List.from(originalDmRelays!);
    markedForDeletion.clear();
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    notifyListeners();
    try {
      final relaysToSave = dmRelays!
          .where((relay) => !markedForDeletion.contains(relay))
          .toList();

      final ndk = GetIt.I<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final unsigned = Nip01Event(
        pubKey: account.pubkey,
        kind: dmRelayListKind,
        tags: relaysToSave.map((relay) => ['relay', relay]).toList(),
        content: '',
      );
      final signed = await account.signer.sign(unsigned);
      await ndk.config.cache.saveEvent(signed);
      // Only read once the NIP-65 list has been found, so the outbox relays it
      // names are enough.
      await GetIt.I<OfflineBroadcast>().broadcast(
        signed,
        relaySet: RelaySet.outbox(account.pubkey),
        pubkey: account.pubkey,
      );
      if (_isDisposed) return;

      dmRelays = relaysToSave;
      originalDmRelays = List.from(relaysToSave);
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
