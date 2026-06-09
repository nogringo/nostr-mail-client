import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:nostr_mail_client/models/address_book_contact_form.dart';
import 'package:nostr_mail_client/services/address_book_service.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  late Database db;
  late Ndk ndk;
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
    book = NostrAddressBook(ndk: ndk, database: db);
    service = Get.put(AddressBookService(book: book, syncOnInit: false));
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    Get.delete<AddressBookService>();
    await book.dispose();
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
}
