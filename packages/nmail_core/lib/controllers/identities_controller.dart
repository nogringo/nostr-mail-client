import 'package:enough_mail_plus/enough_mail.dart';
import 'package:get/get.dart';
import 'package:nostr_mail/nostr_mail.dart' show PrivateSettings;

import 'package:nmail_core/models/local_part_format.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'auth_controller.dart';

class IdentitiesController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();
  final _auth = Get.find<AuthController>();

  final RxList<MailAddress> identities = <MailAddress>[].obs;
  final RxSet<int> markedForDeletion = <int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isSaving = false.obs;

  String? _myNpub;
  String? _myHex;
  String? _myBase36;

  List<MailAddress> _original = const [];
  bool _hasLoadedData = false;
  int _accountGeneration = 0;
  Worker? _accountWorker;

  @override
  void onInit() {
    super.onInit();
    _bindCurrentAccount();
    _accountWorker = ever(_auth.activePubkey, (_) => _rebindAccount());
  }

  @override
  void onClose() {
    _accountWorker?.dispose();
    super.onClose();
  }

  void _bindCurrentAccount() {
    final hex = _auth.publicKey;
    _myHex = hex;
    _myNpub = _auth.npub;
    _myBase36 = hex == null
        ? null
        : BigInt.parse(hex, radix: 16).toRadixString(36);
    if (hex == null || !_nostrMailService.hasAccount) {
      isLoading.value = false;
      return;
    }
    _loadCachedData();
    loadData(preserveLocalChanges: true, fetchFromRelays: true);
  }

  void _rebindAccount() {
    _accountGeneration++;
    _hasLoadedData = false;
    _original = const [];
    identities.clear();
    markedForDeletion.clear();
    isLoading.value = true;
    isRefreshing.value = false;
    _bindCurrentAccount();
  }

  ({LocalPartFormat format, String localPart, String domain})? matchedKeyFormat(
    MailAddress identity,
  ) {
    final email = identity.email;
    final atIndex = email.indexOf('@');
    if (atIndex < 0) return null;
    final local = email.substring(0, atIndex);
    final domain = email.substring(atIndex + 1);
    if (_myNpub != null && local == _myNpub) {
      return (format: LocalPartFormat.npub, localPart: local, domain: domain);
    }
    if (_myHex != null && local == _myHex) {
      return (format: LocalPartFormat.hex, localPart: local, domain: domain);
    }
    if (_myBase36 != null && local == _myBase36) {
      return (format: LocalPartFormat.base36, localPart: local, domain: domain);
    }
    return null;
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
    final settings = _nostrMailService.client.cachedPrivateSettings;
    if (settings == null) return;

    _applySettings(settings);
    isLoading.value = false;
  }

  void _applySettings(PrivateSettings? settings) {
    final loaded = settings?.identities ?? [];
    _original = List.from(loaded);
    identities.assignAll(loaded);
    markedForDeletion.clear();
    _hasLoadedData = true;
  }

  Future<void> loadData({
    bool preserveLocalChanges = false,
    bool fetchFromRelays = false,
  }) async {
    final generation = _accountGeneration;
    if (_hasLoadedData && fetchFromRelays) {
      isRefreshing.value = true;
    } else if (!_hasLoadedData) {
      isLoading.value = true;
    }

    try {
      final settings = fetchFromRelays
          ? await _nostrMailService.client.fetchPrivateSettings()
          : await _nostrMailService.client.getPrivateSettings();
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
        isLoading.value = false;
        isRefreshing.value = false;
      }
    }
  }

  void toggleDeletion(int index) {
    if (markedForDeletion.contains(index)) {
      markedForDeletion.remove(index);
    } else {
      markedForDeletion.add(index);
    }
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
  }

  void discardChanges() {
    identities.assignAll(_original);
    markedForDeletion.clear();
  }

  Future<void> saveChanges() async {
    if (!hasChanges || isSaving.value) return;
    final generation = _accountGeneration;
    isSaving.value = true;
    try {
      final toSave = <MailAddress>[];
      for (int i = 0; i < identities.length; i++) {
        if (!markedForDeletion.contains(i)) toSave.add(identities[i]);
      }
      await _nostrMailService.client.updatePrivateSettings(identities: toSave);
      if (generation != _accountGeneration) return;
      _original = List.from(toSave);
      identities.assignAll(toSave);
      markedForDeletion.clear();
    } finally {
      isSaving.value = false;
    }
  }
}
