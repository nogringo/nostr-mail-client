import 'dart:async';

import 'package:enough_mail_plus/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart' show PrivateSettings;

import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/key_address.dart';
import 'auth_controller.dart';

class IdentitiesController extends ChangeNotifier {
  IdentitiesController() {
    _bindCurrentAccount();
    _accountSubscription = _auth.activePubkey.listen((_) => _rebindAccount());
  }

  final _nostrMailService = Get.find<NostrMailService>();
  final _auth = Get.find<AuthController>();

  List<MailAddress> identities = [];
  final markedForDeletion = <int>{};
  bool isLoading = true;
  bool isRefreshing = false;
  bool isSaving = false;

  String? _myHex;

  List<MailAddress> _original = const [];
  bool _hasLoadedData = false;
  int _accountGeneration = 0;
  late final StreamSubscription<String?> _accountSubscription;

  @override
  void dispose() {
    _accountSubscription.cancel();
    super.dispose();
  }

  void _bindCurrentAccount() {
    final hex = _auth.publicKey;
    _myHex = hex;
    if (hex == null || !_nostrMailService.hasAccount) {
      isLoading = false;
      notifyListeners();
      return;
    }
    _loadCachedData();
    loadData(preserveLocalChanges: true, fetchFromRelays: true);
  }

  void _rebindAccount() {
    _accountGeneration++;
    _hasLoadedData = false;
    _original = const [];
    identities = [];
    markedForDeletion.clear();
    isLoading = true;
    isRefreshing = false;
    notifyListeners();
    _bindCurrentAccount();
  }

  KeyAddressMatch? matchedKeyFormat(MailAddress identity) {
    final hex = _myHex;
    if (hex == null) return null;
    return matchKeyAddress(identity.email, hex);
  }

  bool get hasChanges {
    if (markedForDeletion.isNotEmpty) return true;
    if (_original.length != identities.length) return true;
    for (int i = 0; i < _original.length; i++) {
      if (_original[i].email != identities[i].email ||
          _original[i].personalName != identities[i].personalName) {
        return true;
      }
    }
    return false;
  }

  void _loadCachedData() {
    final settings = _nostrMailService.client.cachedPrivateSettings();
    if (settings == null) return;

    _applySettings(settings);
    isLoading = false;
    notifyListeners();
  }

  void _applySettings(PrivateSettings? settings) {
    final loaded = settings?.identities ?? [];
    _original = List.from(loaded);
    identities = List.of(loaded);
    markedForDeletion.clear();
    _hasLoadedData = true;
  }

  Future<void> loadData({
    bool preserveLocalChanges = false,
    bool fetchFromRelays = false,
  }) async {
    final generation = _accountGeneration;
    if (_hasLoadedData && fetchFromRelays) {
      isRefreshing = true;
    } else if (!_hasLoadedData) {
      isLoading = true;
    }
    notifyListeners();

    try {
      final settings = fetchFromRelays
          ? await _nostrMailService.client.fetchPrivateSettings()
          : await _nostrMailService.client.getLocalPrivateSettings();
      if (generation != _accountGeneration) return;
      if (!preserveLocalChanges || !hasChanges) {
        _applySettings(settings);
      }
    } catch (_) {
      if (generation != _accountGeneration) return;
      if (!_hasLoadedData) {
        _applySettings(null);
      }
    } finally {
      if (generation == _accountGeneration) {
        isLoading = false;
        isRefreshing = false;
        notifyListeners();
      }
    }
  }

  void toggleDeletion(int index) {
    if (markedForDeletion.contains(index)) {
      markedForDeletion.remove(index);
    } else {
      markedForDeletion.add(index);
    }
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    final item = identities.removeAt(oldIndex);
    identities.insert(newIndex, item);

    final shifted = <int>{};
    for (final i in markedForDeletion) {
      if (i == oldIndex) {
        shifted.add(newIndex);
      } else if (oldIndex < newIndex && i > oldIndex && i <= newIndex) {
        shifted.add(i - 1);
      } else if (oldIndex > newIndex && i >= newIndex && i < oldIndex) {
        shifted.add(i + 1);
      } else {
        shifted.add(i);
      }
    }
    markedForDeletion
      ..clear()
      ..addAll(shifted);
    notifyListeners();
  }

  void discardChanges() {
    identities = List.of(_original);
    markedForDeletion.clear();
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving) return;
    final generation = _accountGeneration;
    isSaving = true;
    notifyListeners();
    try {
      final toSave = <MailAddress>[];
      for (int i = 0; i < identities.length; i++) {
        if (!markedForDeletion.contains(i)) toSave.add(identities[i]);
      }
      await _nostrMailService.client.updatePrivateSettings(identities: toSave);
      if (generation != _accountGeneration) return;
      _original = List.from(toSave);
      identities = toSave;
      markedForDeletion.clear();
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
