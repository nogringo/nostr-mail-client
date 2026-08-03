import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class Nip65RelaysController extends GetxController {
  Map<String, ReadWriteMarker>? originalRelays;
  Map<String, ReadWriteMarker>? relays;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;

  bool get hasChanges {
    if (originalRelays == null || relays == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalRelays!.length != relays!.length) return true;
    for (final entry in originalRelays!.entries) {
      if (!relays!.containsKey(entry.key)) return true;
      if (relays![entry.key] != entry.value) return true;
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
    final nip65Relays = await nostrMailService.getNip65Relays();
    if (isClosed) return;

    originalRelays = Map.from(nip65Relays);
    relays = Map.from(nip65Relays);
    isLoading = false;
    update();
  }

  void addRelay(String relay, ReadWriteMarker marker) {
    if (relays == null || relays!.containsKey(relay)) return;
    relays![relay] = marker;
    update();
  }

  void addRecommendedRelay(String relay) {
    addRelay(relay, ReadWriteMarker.readWrite);
  }

  void toggleRelayDeletion(String relayUrl) {
    if (markedForDeletion.contains(relayUrl)) {
      markedForDeletion.remove(relayUrl);
    } else {
      markedForDeletion.add(relayUrl);
    }
    update();
  }

  void discardChanges() {
    if (originalRelays == null) return;
    relays = Map.from(originalRelays!);
    markedForDeletion.clear();
    update();
  }

  void cycleMarker(String relayUrl) {
    if (relays == null || !relays!.containsKey(relayUrl)) return;
    final current = relays![relayUrl]!;
    relays![relayUrl] = switch (current) {
      ReadWriteMarker.readWrite => ReadWriteMarker.readOnly,
      ReadWriteMarker.readOnly => ReadWriteMarker.writeOnly,
      ReadWriteMarker.writeOnly => ReadWriteMarker.readWrite,
    };
    update();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    update();
    try {
      final relaysToSave = Map<String, ReadWriteMarker>.from(relays!)
        ..removeWhere((key, _) => markedForDeletion.contains(key));

      final ndk = Get.find<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final userRelayList = UserRelayList(
        pubKey: account.pubkey,
        relays: relaysToSave,
        createdAt: now,
        refreshedTimestamp: now,
      );
      final signed = await account.signer.sign(
        userRelayList.toNip65().toEvent(),
      );
      await ndk.config.cache.saveUserRelayList(userRelayList);
      // TODO: a relay added here receives only this list, so it hosts a relay
      // list pointing at itself and nothing else. Worse, rotating relays drops
      // data: add B, later remove the A that held the kind 30078, and the
      // identities and bridges are gone from the network while the local cache
      // still shows them. Republish kinds 0, 10050, 10063 and 30078 to the
      // relays added by this save (originalRelays vs relaysToSave), rebroadcasting
      // the cached signed events rather than re-signing, as `adopt()` does.
      // Not the emails: they belong to the DM relay list and moving them is a
      // migration of its own.
      await Get.find<OfflineBroadcast>().broadcast(
        signed,
        relays: {
          ...NostrConfig.popularRelays,
          ...NostrConfig.discoveryRelays,
          ...userRelayList.writeUrls,
        }.toList(),
        pubkey: account.pubkey,
      );
      if (isClosed) return;

      relays = relaysToSave;
      originalRelays = Map.from(relaysToSave);
      markedForDeletion.clear();
    } finally {
      if (!isClosed) {
        isSaving = false;
        update();
      }
    }
  }
}
