import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart' as mail;
import 'package:sembast/sembast_io.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'memory_blossom_cache.dart';

class SeederRuntime {
  final Ndk ndk;
  final Database db;
  final OfflineBroadcast broadcastQueue;
  final SyncEngine syncEngine;
  final mail.NostrMailClient client;
  final String privateKey;
  final String pubkey;

  SeederRuntime._({
    required this.ndk,
    required this.db,
    required this.broadcastQueue,
    required this.syncEngine,
    required this.client,
    required this.privateKey,
    required this.pubkey,
  });

  static Future<SeederRuntime> create({
    required String privateKey,
    required String databasePath,
    required List<String> bootstrapRelays,
    required List<String> defaultDmRelays,
    required List<String> blossomServers,
  }) async {
    final db = await databaseFactoryIo.openDatabase(databasePath);
    final cache = SembastCacheManager(db);
    final ndk = Ndk(
      NdkConfig(
        cache: cache,
        eventVerifier: Bip340EventVerifier(),
        bootstrapRelays: bootstrapRelays,
        defaultBroadcastConsiderDonePercent: 0.0,
        logLevel: LogLevel.warning,
      ),
    );
    final pubkey = Bip340EventSignerFactory().derivePublicKey(privateKey);
    ndk.accounts.loginPrivateKey(pubkey: pubkey, privkey: privateKey);

    final broadcastQueue = OfflineBroadcast.withNdk(ndk, db: db)..start();
    final blossomCache = MemoryBlossomCache();
    final syncEngine = SyncEngine(ndk, db: db);
    final client = await mail.NostrMailClient.create(
      ndk: ndk,
      db: db,
      blossomCache: blossomCache,
      syncEngine: syncEngine,
      defaultDmRelays: defaultDmRelays,
      broadcastQueue: broadcastQueue,
      defaultBlossomServers: blossomServers,
    );

    return SeederRuntime._(
      ndk: ndk,
      db: db,
      broadcastQueue: broadcastQueue,
      syncEngine: syncEngine,
      client: client,
      privateKey: privateKey,
      pubkey: pubkey,
    );
  }

  Future<Nip01Event> sign(Nip01Event event) async {
    return ndk.accounts.getLoggedAccount()!.signer.sign(event);
  }

  Future<void> dispose() async {
    await client.dispose();
    await syncEngine.dispose();
    await broadcastQueue.dispose();
    await ndk.destroy();
    await db.close();
  }
}
