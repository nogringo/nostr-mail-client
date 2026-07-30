import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class DmRelaysController extends GetxController {
  List<String>? originalDmRelays;
  List<String>? dmRelays;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;

  bool get hasChanges {
    if (originalDmRelays == null || dmRelays == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalDmRelays!.length != dmRelays!.length) return true;
    for (final relay in originalDmRelays!) {
      if (!dmRelays!.contains(relay)) return true;
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
    final relays = await nostrMailService.getDmRelays();
    if (isClosed) return;

    originalDmRelays = List.from(relays);
    dmRelays = List.from(relays);
    isLoading = false;
    update();
  }

  void addRelay(String relay) {
    if (dmRelays == null || dmRelays!.contains(relay)) return;
    dmRelays!.add(relay);
    update();
  }

  void toggleRelayDeletion(String relayUrl) {
    if (markedForDeletion.contains(relayUrl)) {
      markedForDeletion.remove(relayUrl);
    } else {
      markedForDeletion.add(relayUrl);
    }
    update();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    update();
    try {
      final relaysToSave = dmRelays!
          .where((relay) => !markedForDeletion.contains(relay))
          .toList();

      final ndk = Get.find<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final unsigned = Nip01Event(
        pubKey: account.pubkey,
        kind: dmRelayListKind,
        tags: relaysToSave.map((relay) => ['relay', relay]).toList(),
        content: '',
      );
      final signed = await account.signer.sign(unsigned);
      await ndk.config.cache.saveEvent(signed);
      final outbox = await Get.find<NostrMailService>().getOutboxRelays();
      await Get.find<OfflineBroadcast>().broadcast(
        signed,
        relays: {...NostrConfig.popularRelays, ...outbox}.toList(),
        pubkey: account.pubkey,
      );
      if (isClosed) return;

      dmRelays = relaysToSave;
      originalDmRelays = List.from(relaysToSave);
      markedForDeletion.clear();
    } finally {
      if (!isClosed) {
        isSaving = false;
        update();
      }
    }
  }
}
