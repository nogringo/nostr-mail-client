import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_mail/nostr_mail.dart' as mail;
import 'package:sembast/sembast_io.dart';

import 'memory_blossom_cache.dart';

class SeederRuntime {
  final Ndk ndk;
  final Database db;
  final OfflineBroadcast broadcastQueue;
  final mail.NostrMailClient client;
  final String privateKey;
  final String pubkey;

  SeederRuntime._({
    required this.ndk,
    required this.db,
    required this.broadcastQueue,
    required this.client,
    required this.privateKey,
    required this.pubkey,
  });

  static Future<SeederRuntime> create({
    required String privateKey,
    required String databasePath,
    required List<String> bootstrapRelays,
    required List<String> defaultDmRelays,
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
    final client = await mail.NostrMailClient.create(
      ndk: ndk,
      db: db,
      blossomCache: blossomCache,
      defaultDmRelays: defaultDmRelays,
      broadcastQueue: broadcastQueue,
      defaultBlossomServers: const [],
    );

    return SeederRuntime._(
      ndk: ndk,
      db: db,
      broadcastQueue: broadcastQueue,
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
    await broadcastQueue.dispose();
    await ndk.destroy();
    await db.close();
  }
}
