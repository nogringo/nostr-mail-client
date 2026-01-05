import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';
import 'package:nostr_mail/nostr_mail.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';

import 'storage_service.dart';

class NostrMailService extends GetxService {
  NostrMailClient? _client;
  late Ndk _ndk;

  final _storageService = Get.find<StorageService>();

  NostrMailClient get client {
    if (_client == null) {
      throw Exception(
        'NostrMailClient not initialized. Call initClient() first.',
      );
    }
    return _client!;
  }

  Ndk get ndk => _ndk;

  bool get isClientInitialized => _client != null;

  Future<void> initNdk() async {
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
  }

  void initClient() {
    _client = NostrMailClient(ndk: _ndk, db: _storageService.db);
  }

  String? getPublicKey() {
    return _ndk.accounts.getPublicKey();
  }

  Future<void> logout() async {
    _ndk.accounts.logout();
    _client = null;
  }
}
