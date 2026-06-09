import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../models/address_book_contact_form.dart';
import '../models/contact.dart';
import '../utils/address_book_vcard_mapper.dart';
import 'storage_service.dart';

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
        NostrAddressBook(ndk: _ndk, database: Get.find<StorageService>().db);
    _watchSubscription = _book.watchAll().listen(_setVisibleContacts);
    _authSubscription = _ndk.accounts.authStateChanges.listen((_) {
      unawaited(load(sync: true));
    });
    _book.broadcastQueue.start();
    unawaited(load(sync: syncOnInit));
  }

  @override
  void onClose() {
    _watchSubscription?.cancel();
    _authSubscription?.cancel();
    if (_injectedBook == null) {
      unawaited(_book.dispose());
    }
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

  List<Contact> suggestionContacts() {
    return contacts
        .expand(AddressBookVCardMapper.suggestionsFromContact)
        .toList(growable: false);
  }

  Future<String?> resolveNostrIdentifier(String input) async {
    final direct = AddressBookVCardMapper.normalizeNostrPubkey(input);
    if (direct != null) return direct;

    final value = input.trim();
    if (!value.contains('@')) return null;
    final parts = value.split('@');
    if (parts.length != 2 || parts.any((part) => part.isEmpty)) return null;

    try {
      // TODO: Use NDK's NIP-05 resolver here instead of maintaining a
      // separate .well-known/nostr.json implementation in the app.
      final response = await http
          .get(
            Uri.https(parts[1], '/.well-known/nostr.json', {'name': parts[0]}),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final names = body['names'] as Map<String, dynamic>?;
      final pubkey = names?[parts[0]] as String?;
      if (pubkey == null) return null;
      return AddressBookVCardMapper.normalizeNostrPubkey(pubkey);
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
}
