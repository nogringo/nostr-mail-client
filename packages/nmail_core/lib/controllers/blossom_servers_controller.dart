import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

class BlossomServersController extends GetxController {
  List<String>? originalServers;
  List<String>? servers;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;

  bool get hasChanges {
    if (originalServers == null || servers == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalServers!.length != servers!.length) return true;
    for (final server in originalServers!) {
      if (!servers!.contains(server)) return true;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    final nostrMailService = Get.find<NostrMailService>();
    final blossomServers = await nostrMailService.getBlossomServers();
    if (isClosed) return;

    originalServers = List.from(blossomServers);
    servers = List.from(blossomServers);
    isLoading = false;
    update();
  }

  void addServer(String server) {
    if (servers == null || servers!.contains(server)) return;
    servers!.add(server);
    update();
  }

  void toggleServerDeletion(String serverUrl) {
    if (markedForDeletion.contains(serverUrl)) {
      markedForDeletion.remove(serverUrl);
    } else {
      markedForDeletion.add(serverUrl);
    }
    update();
  }

  void discardChanges() {
    if (originalServers == null) return;
    servers = List.from(originalServers!);
    markedForDeletion.clear();
    update();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    update();
    try {
      final serversToSave = servers!
          .where((server) => !markedForDeletion.contains(server))
          .toList();

      final ndk = Get.find<Ndk>();
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
      final outbox = await Get.find<NostrMailService>().getOutboxRelays();
      await Get.find<OfflineBroadcast>().broadcast(
        signed,
        relays: outbox,
        pubkey: account.pubkey,
      );
      if (isClosed) return;

      servers = serversToSave;
      originalServers = List.from(serversToSave);
      markedForDeletion.clear();
    } finally {
      if (!isClosed) {
        isSaving = false;
        update();
      }
    }
  }
}
