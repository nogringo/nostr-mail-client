import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:nmail_core/services/nostr_mail_service.dart';

class BridgesController extends ChangeNotifier {
  BridgesController() {
    loadData();
  }

  List<String>? originalBridges;
  List<String>? bridges;
  final Set<String> markedForDeletion = {};
  bool isLoading = true;
  bool isSaving = false;
  bool _isDisposed = false;

  bool get hasChanges {
    if (originalBridges == null || bridges == null) return false;
    if (markedForDeletion.isNotEmpty) return true;
    if (originalBridges!.length != bridges!.length) return true;
    for (final bridge in originalBridges!) {
      if (!bridges!.contains(bridge)) return true;
    }
    return false;
  }

  Future<void> loadData() async {
    try {
      final nostrMailService = GetIt.I<NostrMailService>();
      final settings = await nostrMailService.client.getLocalPrivateSettings();
      final loadedBridges = settings?.bridges ?? [];
      if (_isDisposed) return;

      originalBridges = List.from(loadedBridges);
      bridges = List.from(loadedBridges);
    } catch (_) {
      if (_isDisposed) return;

      originalBridges = [];
      bridges = [];
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void addBridge(String bridge) {
    if (bridges == null || bridges!.contains(bridge)) return;
    bridges!.add(bridge);
    notifyListeners();
  }

  void toggleBridgeDeletion(String bridge) {
    if (markedForDeletion.contains(bridge)) {
      markedForDeletion.remove(bridge);
    } else {
      markedForDeletion.add(bridge);
    }
    notifyListeners();
  }

  void discardChanges() {
    if (originalBridges == null) return;
    bridges = List.from(originalBridges!);
    markedForDeletion.clear();
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    isSaving = true;
    notifyListeners();
    try {
      final nostrMailService = GetIt.I<NostrMailService>();
      final bridgesToSave = bridges!
          .where((bridge) => !markedForDeletion.contains(bridge))
          .toList();
      await nostrMailService.client.updatePrivateSettings(
        bridges: bridgesToSave,
      );
      if (_isDisposed) return;

      bridges = bridgesToSave;
      originalBridges = List.from(bridgesToSave);
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
