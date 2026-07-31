import 'package:flutter_test/flutter_test.dart';
import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart' show Nip05;
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/services/address_book_service.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late Ndk ndk;
  late OfflineBroadcast broadcastQueue;
  late NostrAddressBook book;
  late AddressBookService service;

  setUp(() async {
    Get.testMode = true;
    db = await databaseFactoryMemory.openDatabase('address_book_service.db');
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(useIsolate: false),
        bootstrapRelays: const [],
        logLevel: LogLevel.off,
      ),
    );
    const factory = Bip340EventSignerFactory();
    final (privateKey, pubkey) = factory.generateKeyPair();
    ndk.accounts.loginPrivateKey(pubkey: pubkey, privkey: privateKey);
    Get.put<Ndk>(ndk);
    broadcastQueue = OfflineBroadcast.withNdk(ndk, db: db);
    book = NostrAddressBook(
      ndk: ndk,
      database: db,
      broadcastQueue: broadcastQueue,
    );
    service = Get.put(AddressBookService(book: book, syncOnInit: false));
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    Get.delete<AddressBookService>();
    await broadcastQueue.dispose();
    await ndk.destroy();
    await db.close();
    Get.reset();
  });

  test('saves active contacts for the current account', () async {
    await service.saveContact(
      const AddressBookContactForm(
        displayName: 'Alice Example',
        emails: ['alice@example.com'],
      ),
    );

    expect(service.contacts, hasLength(1));
    expect(service.contacts.single.index.formattedName, 'Alice Example');
    expect(service.contacts.single.pubKey, ndk.accounts.getPublicKey());
  });

  test('delete removes contacts from active list', () async {
    final contact = await service.saveContact(
      const AddressBookContactForm(
        displayName: 'Bob Example',
        emails: ['bob@example.com'],
      ),
    );

    await service.deleteContact(contact);

    expect(service.contacts, isEmpty);
  });

  test('resolves NIP-05 identifiers through NDK cache', () async {
    const identifier = 'carol@example.com';
    const factory = Bip340EventSignerFactory();
    final (_, resolvedPubkey) = factory.generateKeyPair();
    await ndk.config.cache.saveNip05(
      Nip05(
        pubKey: resolvedPubkey,
        nip05: identifier,
        valid: true,
        networkFetchTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ),
    );

    final contact = await service.saveContact(
      const AddressBookContactForm(
        displayName: 'Carol Example',
        nostrPubkeys: [identifier],
      ),
    );

    expect(
      AddressBookVCardMapper.normalizeNostrPubkey(
        contact.index.nostrIdentifiers.single,
      ),
      resolvedPubkey,
    );
  });
}
