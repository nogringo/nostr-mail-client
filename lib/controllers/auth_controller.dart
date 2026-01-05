import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_widgets/nostr_widgets.dart';

import '../services/nostr_mail_service.dart';

class AuthController extends GetxController {
  final _nostrMailService = Get.find<NostrMailService>();

  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final Rxn<Metadata> userMetadata = Rxn<Metadata>();

  Ndk get ndk => _nostrMailService.ndk;

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    isLoading.value = true;
    try {
      await _nostrMailService.initNdk();
      await nRestoreAccounts(ndk);

      if (ndk.accounts.getPublicKey() != null) {
        _nostrMailService.initClient();
        isLoggedIn.value = true;
        loadUserMetadata();
      }
    } catch (e) {
      // Si erreur, on reste sur la page de login
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserMetadata() async {
    final pk = publicKey;
    if (pk == null) return;

    try {
      final metadata = await ndk.metadata.loadMetadata(pk);
      userMetadata.value = metadata;
    } catch (_) {}
  }

  void onLoggedIn() {
    _nostrMailService.initClient();
    isLoggedIn.value = true;
    loadUserMetadata();
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _nostrMailService.logout();
      await nSaveAccountsState(ndk);
      isLoggedIn.value = false;
      userMetadata.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  String? get publicKey => _nostrMailService.getPublicKey();

  String? get npub {
    final pk = publicKey;
    if (pk == null) return null;
    return Nip19.encodePubKey(pk);
  }

  String? getNsec() {
    final account = ndk.accounts.getLoggedAccount();
    if (account == null || account.type != AccountType.privateKey) return null;

    final signer = account.signer as Bip340EventSigner;
    if (signer.privateKey == null) return null;

    return Nip19.encodePrivateKey(signer.privateKey!);
  }
}
