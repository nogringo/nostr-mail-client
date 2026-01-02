import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/bip340.dart';
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';

import 'storage_service.dart';

class NostrMailService extends GetxService {
  NostrMailClient? _client;
  Ndk? _ndk;

  final _storageService = Get.find<StorageService>();

  NostrMailClient get client {
    if (_client == null) {
      throw Exception('NostrMailClient not initialized. Call init() first.');
    }
    return _client!;
  }

  Ndk get ndk {
    if (_ndk == null) {
      throw Exception('NDK not initialized. Call init() first.');
    }
    return _ndk!;
  }

  bool get isInitialized => _client != null;

  Future<void> init(String privateKey) async {
    final pubkey = Bip340.getPublicKey(privateKey);

    final cacheManager = SembastCacheManager(_storageService.db);

    _ndk = Ndk(
      NdkConfig(
        eventVerifier: RustEventVerifier(),
        cache: cacheManager,
        bootstrapRelays: [
          'wss://relay.damus.io',
          'wss://nos.lol',
          'wss://relay.nostr.band',
        ],
      ),
    );

    _ndk!.accounts.loginPrivateKey(pubkey: pubkey, privkey: privateKey);

    _client = NostrMailClient(ndk: _ndk!, db: _storageService.db);
  }

  String? getPublicKey() {
    return _ndk?.accounts.getPublicKey();
  }

  Future<void> logout() async {
    _client = null;
    _ndk = null;
  }
}
