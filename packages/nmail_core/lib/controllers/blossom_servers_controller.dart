import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart' hide RelaySet;

import 'package:nmail_core/services/nostr_mail_service.dart';

class BlossomServersController extends ChangeNotifier {
  BlossomServersController() {
    loadData();
  }

  List<String>? originalServers;
  List<String>? servers;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;
  bool _isDisposed = false;

  bool get hasChanges {
    if (originalServers == null || servers == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalServers!.length != servers!.length) return true;
    for (final server in originalServers!) {
      if (!servers!.contains(server)) return true;
    }
    return false;
  }

  Future<void> loadData() async {
    final nostrMailService = Get.find<NostrMailService>();
    final blossomServers = await nostrMailService.getBlossomServers();
    if (_isDisposed) return;

    originalServers = List.from(blossomServers);
    servers = List.from(blossomServers);
    isLoading = false;
    notifyListeners();
  }

  void addServer(String server) {
    if (servers == null || servers!.contains(server)) return;
    servers!.add(server);
    notifyListeners();
  }

  void toggleServerDeletion(String serverUrl) {
    if (markedForDeletion.contains(serverUrl)) {
      markedForDeletion.remove(serverUrl);
    } else {
      markedForDeletion.add(serverUrl);
    }
    notifyListeners();
  }

  void discardChanges() {
    if (originalServers == null) return;
    servers = List.from(originalServers!);
    markedForDeletion.clear();
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    notifyListeners();
    try {
      final serversToSave = servers!
          .where((server) => !markedForDeletion.contains(server))
          .toList();

      final ndk = GetIt.I<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final unsigned = Nip01Event(
        pubKey: account.pubkey,
        kind: blossomServerListKind,
        tags: [
          for (final server in serversToSave) ['server', server],
        ],
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

      servers = serversToSave;
      originalServers = List.from(serversToSave);
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
