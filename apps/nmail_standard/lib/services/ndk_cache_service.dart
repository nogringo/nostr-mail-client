import 'package:ndk/ndk.dart';

import 'storage_service.dart';

class NdkCacheService {
  static Future<CacheManager> createCacheManager(
    StorageService storageService,
  ) async {
    // Use Sembast for all platforms — no ObjectBox dependency
    return SembastCacheManager(storageService.db);
  }
}
