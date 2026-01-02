import 'package:get/get.dart';
import 'package:ndk/shared/nips/nip19/nip19.dart';

import '../services/nostr_mail_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _nostrMailService = Get.find<NostrMailService>();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    isLoading.value = true;
    try {
      final privateKey = await _storageService.getPrivateKey();
      if (privateKey != null && privateKey.isNotEmpty) {
        await _nostrMailService.init(privateKey);
        isLoggedIn.value = true;
      }
    } catch (e) {
      await _storageService.deletePrivateKey();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String input) async {
    isLoading.value = true;
    try {
      final privateKey = _parsePrivateKey(input.trim());
      if (privateKey == null || privateKey.isEmpty) {
        return false;
      }

      await _nostrMailService.init(privateKey);
      await _storageService.savePrivateKey(privateKey);
      isLoggedIn.value = true;
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _nostrMailService.logout();
      await _storageService.deletePrivateKey();
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  String? _parsePrivateKey(String input) {
    // Handle nsec format
    if (input.startsWith('nsec1')) {
      try {
        final decoded = Nip19.decode(input);
        return decoded.isNotEmpty ? decoded : null;
      } catch (e) {
        return null;
      }
    }

    // Handle hex format (64 chars)
    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(input)) {
      return input.toLowerCase();
    }

    return null;
  }

  String? get publicKey => _nostrMailService.getPublicKey();
}
