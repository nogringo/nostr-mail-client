import 'package:get/get.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

class BridgesController extends GetxController {
  List<String>? originalBridges;
  List<String>? bridges;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;

  bool get hasChanges {
    if (originalBridges == null || bridges == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalBridges!.length != bridges!.length) return true;
    for (final bridge in originalBridges!) {
      if (!bridges!.contains(bridge)) return true;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final nostrMailService = Get.find<NostrMailService>();
      final settings = await nostrMailService.client.getPrivateSettings();
      final loadedBridges = settings?.bridges ?? [];
      if (isClosed) return;

      originalBridges = List.from(loadedBridges);
      bridges = List.from(loadedBridges);
    } catch (_) {
      if (isClosed) return;

      originalBridges = [];
      bridges = [];
    } finally {
      if (!isClosed) {
        isLoading = false;
        update();
      }
    }
  }

  void addBridge(String bridge) {
    if (bridges == null || bridges!.contains(bridge)) return;
    bridges!.add(bridge);
    update();
  }

  void toggleBridgeDeletion(String bridge) {
    if (markedForDeletion.contains(bridge)) {
      markedForDeletion.remove(bridge);
    } else {
      markedForDeletion.add(bridge);
    }
    update();
  }

  void discardChanges() {
    if (originalBridges == null) return;
    bridges = List.from(originalBridges!);
    markedForDeletion.clear();
    update();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    update();
    try {
      final nostrMailService = Get.find<NostrMailService>();
      final bridgesToSave = bridges!
          .where((bridge) => !markedForDeletion.contains(bridge))
          .toList();
      await nostrMailService.client.updatePrivateSettings(
        bridges: bridgesToSave,
      );
      if (isClosed) return;

      bridges = bridgesToSave;
      originalBridges = List.from(bridgesToSave);
      markedForDeletion.clear();
    } finally {
      if (!isClosed) {
        isSaving = false;
        update();
      }
    }
  }
}
