import 'package:enough_mail_plus/enough_mail.dart';
import 'package:get/get.dart';

import '../models/local_part_format.dart';
import '../services/nostr_mail_service.dart';
import 'auth_controller.dart';

class IdentitiesController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final RxList<MailAddress> identities = <MailAddress>[].obs;
  final RxSet<int> markedForDeletion = <int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  late final String? _myNpub;
  late final String? _myHex;
  late final String? _myBase36;

  List<MailAddress> _original = const [];

  @override
  void onInit() {
    super.onInit();
    final auth = Get.find<AuthController>();
    _myHex = auth.publicKey;
    _myNpub = auth.npub;
    _myBase36 = _myHex == null
        ? null
        : BigInt.parse(_myHex, radix: 16).toRadixString(36);
    loadData();
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

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final settings = await _nostrMailService.client.getPrivateSettings();
      final loaded = settings?.identities ?? [];
      _original = List.from(loaded);
      identities.assignAll(loaded);
      markedForDeletion.clear();
    } catch (_) {
      _original = const [];
      identities.clear();
      markedForDeletion.clear();
    } finally {
      isLoading.value = false;
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
    isSaving.value = true;
    try {
      final toSave = <MailAddress>[];
      for (int i = 0; i < identities.length; i++) {
        if (!markedForDeletion.contains(i)) toSave.add(identities[i]);
      }
      await _nostrMailService.client.updatePrivateSettings(identities: toSave);
      _original = List.from(toSave);
      identities.assignAll(toSave);
      markedForDeletion.clear();
    } finally {
      isSaving.value = false;
    }
  }
}
