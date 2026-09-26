import 'dart:typed_data';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:idb_shim/idb_client_memory.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/services/account_local_data_service.dart';
import 'package:nmail_core/services/storage_service.dart';

void main() {
  late Ndk ndk;
  late _MemoryStorage storage;
  late BlossomCache cache;
  late AccountLocalDataService service;
  late String alice;
  late String bob;
  late String sha256;
  late String background;

  setUp(() async {
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(useIsolate: false),
        bootstrapRelays: const [],
        logLevel: LogLevel.off,
      ),
    );

    const factory = Bip340EventSignerFactory();
    final (alicePrivkey, alicePubkey) = factory.generateKeyPair();
    final (bobPrivkey, bobPubkey) = factory.generateKeyPair();
    alice = alicePubkey;
    bob = bobPubkey;
    ndk.accounts.loginPrivateKey(pubkey: bob, privkey: bobPrivkey);
    ndk.accounts.loginPrivateKey(pubkey: alice, privkey: alicePrivkey);

    storage = _MemoryStorage();
    cache = await IdbBlossomCache.open(factory: newIdbFactoryMemory());
    Get.put<Ndk>(ndk);
    Get.put<StorageService>(storage);
    Get.put<BlossomCache>(cache);
    service = AccountLocalDataService();

    final blob = await cache.put(Uint8List.fromList([1, 2, 3]), pinned: true);
    sha256 = blob.sha256;
    background = BackgroundPreset.cachedImageValue(sha256);
  });

  tearDown(() async {
    await ndk.destroy();
    Get.reset();
  });

  test('keeps a cached background another account still shows', () async {
    storage.values['background_image_$alice'] = 'preset:soft_gradient';
    storage.values['background_image_$bob'] = background;

    await service.releaseCachedBackground(background);

    expect(await cache.head(sha256), isNotNull);
  });

  test('deletes a cached background no account shows anymore', () async {
    storage.values['background_image_$alice'] = 'preset:soft_gradient';

    await service.releaseCachedBackground(background);

    expect(await cache.head(sha256), isNull);
  });

  test(
    'removing the last account that shows it deletes the background',
    () async {
      storage.values['background_image_$alice'] = background;
      storage.values['background_image_$bob'] = background;

      await service.clearLocalAccountData(pubkey: alice);
      expect(await cache.head(sha256), isNotNull);

      await service.clearLocalAccountData(pubkey: bob);
      expect(await cache.head(sha256), isNull);
    },
  );
}

class _MemoryStorage extends StorageService {
  final values = <String, dynamic>{};

  @override
  Future<void> saveSetting(String key, dynamic value) async {
    values[key] = value;
  }

  @override
  Future<T?> getSetting<T>(String key) async => values[key] as T?;

  @override
  Future<void> deleteSetting(String key) async {
    values.remove(key);
  }
}
