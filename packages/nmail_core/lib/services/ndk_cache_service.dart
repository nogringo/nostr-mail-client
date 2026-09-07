import 'package:ndk/ndk.dart';
import 'package:ndk_drift/ndk_drift.dart';
import 'package:sembast/sembast.dart';

import 'package:nmail_core/services/storage_service.dart';

/// Stores `SembastCacheManager` kept in the app database before the ndk cache
/// moved to drift. Sembast loads every store in memory, so they are dropped
/// rather than left behind.
const legacySembastCacheStores = [
  'events',
  'event_cache_state',
  'event_sources',
  'event_delivery_records',
  'relay_delivery_targets',
  'decrypted_event_payloads',
  'metadata',
  'contact_lists',
  'relay_lists',
  'nip05',
  'relay_sets',
  'keysets',
  'proofs',
  'mint_infos',
  'secret_counters',
  'filter_fetched_ranges',
];

class NdkCacheService {
  static Future<CacheManager> createCacheManager(
    StorageService storageService,
  ) async {
    await dropLegacySembastCacheStores(storageService.db);
    return DriftCacheManager.create();
  }

  /// Idempotent.
  static Future<void> dropLegacySembastCacheStores(Database db) =>
      db.transaction((txn) async {
        for (final name in legacySembastCacheStores) {
          await StoreRef<Object?, Object?>(name).drop(txn);
        }
      });
}
