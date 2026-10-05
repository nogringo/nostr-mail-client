import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:nmail_core/services/contacts_service.dart';
import 'package:nmail_core/services/metadata_service.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';

import '../helpers/fake_metadata_service.dart';

const _bobPubkey =
    '82341f882b6eabcd2ba7f1ef90aad961cf074af15b9ef44a09f9d2a8fbfbe6a2';

void main() {
  late Ndk ndk;
  late FakeMetadataService metadataService;
  late ContactsService contactsService;

  setUp(() {
    Get.testMode = true;
    ndk = Ndk(
      NdkConfig(
        cache: MemCacheManager(),
        eventVerifier: Bip340EventVerifier(useIsolate: false),
        bootstrapRelays: const [],
        logLevel: LogLevel.off,
      ),
    );
    GetIt.I.registerSingleton<Ndk>(ndk);
    GetIt.I.registerSingleton(StorageService());
    GetIt.I.registerSingleton(NostrMailService());
    metadataService = FakeMetadataService();
    Get.put<MetadataService>(metadataService);
    contactsService = Get.put(ContactsService());
  });

  tearDown(() async {
    Get.reset();
    await GetIt.I.reset();
    await ndk.destroy();
  });

  test('keeps a resolved profile that a later load did not read', () async {
    metadataService.resolve(Metadata(pubKey: _bobPubkey, name: 'Bob Stone'));
    await pumpEventQueue();

    await contactsService.loadContacts();

    expect(
      contactsService.contacts.map((contact) => contact.pubkey),
      contains(_bobPubkey),
    );
  });
}
