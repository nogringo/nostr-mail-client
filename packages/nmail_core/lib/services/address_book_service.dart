import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:enough_mail_plus/enough_mail.dart' as mail;
import 'package:get/get.dart';
import 'package:ndk/entities.dart' show Nip05Found;
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/services/storage_service.dart';

class AddressBookService extends GetxService {
  AddressBookService({NostrAddressBook? book, this.syncOnInit = true})
    : _injectedBook = book;

  final NostrAddressBook? _injectedBook;
  final bool syncOnInit;
  late final NostrAddressBook _book;
  late final Ndk _ndk;

  final contacts = <AddressBookContact>[].obs;
  final isLoading = false.obs;
  final isSyncing = false.obs;
  final lastError = RxnString();

  StreamSubscription<List<AddressBookContact>>? _watchSubscription;
  StreamSubscription? _authSubscription;

  String? get _currentPubkey => _ndk.accounts.getPublicKey();

  @override
  void onInit() {
    super.onInit();
    _ndk = Get.find<Ndk>();
    _book =
        _injectedBook ??
        NostrAddressBook(
          ndk: _ndk,
          database: Get.find<StorageService>().db,
          broadcastQueue: Get.find<OfflineBroadcast>(),
        );
    _watchSubscription = _book.watchAll().listen(_setVisibleContacts);
    _authSubscription = _ndk.accounts.authStateChanges.listen((_) {
      unawaited(load(sync: true));
    });
    unawaited(load(sync: syncOnInit));
  }

  @override
  void onClose() {
    _watchSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> load({bool sync = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    lastError.value = null;
    try {
      await _book.rebuildComputedStores();
      _setVisibleContacts(await _book.list());
    } catch (error) {
      lastError.value = error.toString();
    } finally {
      isLoading.value = false;
    }
    if (sync && _currentPubkey != null) {
      unawaited(fetchRecent());
    }
  }

  Future<void> fetchRecent() async {
    if (isSyncing.value || _currentPubkey == null) return;
    isSyncing.value = true;
    lastError.value = null;
    try {
      await _book.fetchRecent();
      _setVisibleContacts(await _book.list());
    } catch (error) {
      lastError.value = error.toString();
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> pull() async {
    if (isSyncing.value || _currentPubkey == null) return;
    isSyncing.value = true;
    lastError.value = null;
    try {
      await _book.pull(paginate: true);
      _setVisibleContacts(await _book.list());
    } catch (error) {
      lastError.value = error.toString();
    } finally {
      isSyncing.value = false;
    }
  }

  Future<AddressBookContact> saveContact(
    AddressBookContactForm form, {
    AddressBookContact? existing,
  }) async {
    final normalizedPubkeys = <String>[];
    for (final input in form.nostrPubkeys) {
      final pubkey = await resolveNostrIdentifier(input);
      if (pubkey == null) {
        throw AddressBookValidationException(
          'Invalid Nostr identifier: $input',
        );
      }
      normalizedPubkeys.add(pubkey);
    }

    final vCard = AddressBookVCardMapper.buildVCard(
      form.copyWith(
        uid: form.uid ?? existing?.uid,
        nostrPubkeys: normalizedPubkeys,
      ),
      existingVCard: existing?.vCard,
    );
    final saved = await _book.upsertVCard(vCard);
    _setVisibleContacts(await _book.list());
    return saved;
  }

  Future<void> deleteContact(AddressBookContact contact) async {
    await _book.delete(contact.uid);
    _setVisibleContacts(await _book.list());
  }

  Future<void> retryBroadcasts() => _book.broadcastQueue.retryNow();

  Future<void> clearLocalAccountData({required String pubkey}) async {
    await _book.clearLocalAccountData(pubkey: pubkey);
    _setVisibleContacts(await _book.list());
  }

  Future<void> clearAllLocalData() async {
    await _book.clearAllLocalData();
    _setVisibleContacts(await _book.list());
  }

  List<Contact> suggestionContacts() {
    return contacts.expand(_suggestionsFromContact).toList(growable: false);
  }

  Future<String?> resolveNostrIdentifier(String input) async {
    final direct = AddressBookVCardMapper.normalizeNostrPubkey(input);
    if (direct != null) return direct;

    final value = input.trim();
    if (!value.contains('@')) return null;
    final parts = value.split('@');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) return null;

    try {
      final result = await _ndk.nip05.resolve(value);
      if (result is! Nip05Found) return null;
      return AddressBookVCardMapper.normalizeNostrPubkey(result.data.pubKey);
    } catch (_) {
      return null;
    }
  }

  void _setVisibleContacts(List<AddressBookContact> allContacts) {
    final pubkey = _currentPubkey;
    if (pubkey == null) {
      contacts.value = [];
      return;
    }
    contacts.value = allContacts
        .where((contact) => !contact.deleted && contact.pubKey == pubkey)
        .toList(growable: false);
  }

  Iterable<Contact> _suggestionsFromContact(AddressBookContact contact) {
    final name = contact.index.formattedName.trim().isNotEmpty
        ? contact.index.formattedName.trim()
        : null;

    return [
      for (final email in contact.index.emails)
        Contact(
          displayName: name,
          mailAddress: mail.MailAddress(name, email),
          source: ContactSource.addressBook,
          addressBookUid: contact.uid,
          contactMethodId: 'email:${email.toLowerCase()}',
        ),
      for (final pubkey
          in contact.index.nostrIdentifiers
              .map(AddressBookVCardMapper.normalizeNostrPubkey)
              .whereType<String>())
        Contact(
          pubkey: pubkey,
          displayName: name,
          source: ContactSource.addressBook,
          addressBookUid: contact.uid,
          contactMethodId: 'nostr:$pubkey',
        ),
    ];
  }
}
