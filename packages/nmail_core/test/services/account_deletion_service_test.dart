import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nmail_core/services/account_deletion_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  group('AccountDeletionService', () {
    test('builds a NIP-62 global vanish event', () {
      final event = AccountDeletionService.buildGlobalVanishEvent(
        pubkey: 'a' * 64,
        createdAt: 123,
      );

      expect(event.kind, AccountDeletionService.vanishKind);
      expect(event.pubKey, 'a' * 64);
      expect(event.tags, [
        ['relay', AccountDeletionService.allRelaysTagValue],
      ]);
      expect(event.content, isNotEmpty);
      expect(event.createdAt, 123);
    });

    test(
      'mergeTargetRelays normalizes, deduplicates, and drops invalid URLs',
      () {
        final relays = AccountDeletionService.mergeTargetRelays([
          ['relay.example.com', 'wss://relay.example.com'],
          ['ws://localhost', 'not a relay', 'https://example.com'],
        ]);

        expect(relays, ['wss://relay.example.com', 'ws://localhost']);
      },
    );

    test('clearAll purges storage service settings only', () async {
      final db = await databaseFactoryMemory.openDatabase('delete_account.db');
      final storage = await StorageService(database: db).init();

      await StoreRef<String, Object?>('settings').record('theme').put(db, 1);
      await StoreRef<String, Object?>(
        'emails',
      ).record('email-1').put(db, {'subject': 'Hello'});

      await storage.clearAll();

      expect(await StoreRef<String, Object?>('settings').count(db), 0);
      expect(await StoreRef<String, Object?>('emails').count(db), 1);

      await db.close();
      Get.reset();
    });
  });
}
