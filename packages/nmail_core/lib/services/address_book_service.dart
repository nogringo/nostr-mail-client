import 'dart:async';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:enough_mail_plus/enough_mail.dart' as mail;
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/entities.dart' show Nip05Found;
import 'package:ndk/ndk.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/utils/address_book_vcard_mapper.dart';
import 'package:nostr_address_book/nostr_address_book.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'package:nmail_core/models/contact.dart';
import 'package:nmail_core/services/storage_service.dart';

class AddressBookService {
  AddressBookService({NostrAddressBook? book}) : _injectedBook = book;

  final NostrAddressBook? _injectedBook;
  late final NostrAddressBook _book;
  late final Ndk _ndk;

  final contacts = ValueNotifier<List<AddressBookContact>>(const []);
  final isLoading = ValueNotifier(false);
  final isSyncing = ValueNotifier(false);
  final lastError = ValueNotifier<String?>(null);

  StreamSubscription<List<AddressBookContact>>? _watchSubscription;
  StreamSubscription? _authSubscription;

  String? get _currentPubkey => _ndk.accounts.getPublicKey();

  void start({bool sync = true}) {
    _ndk = GetIt.I<Ndk>();
    _book =
        _injectedBook ??
        NostrAddressBook(
          ndk: _ndk,
          database: GetIt.I<StorageService>().db,
          broadcastQueue: GetIt.I<OfflineBroadcast>(),
          syncEngine: GetIt.I<SyncEngine>(),
        );
    _watchSubscription = _book.watchAll().listen(_setVisibleContacts);
    _authSubscription = _ndk.accounts.authStateChanges.listen((_) {
      _book.stopAllSync();
      unawaited(load(sync: true));
    });
    unawaited(load(sync: sync));
  }

  void dispose() {
    _book.stopAllSync();
    _watchSubscription?.cancel();
    _authSubscription?.cancel();
    contacts.dispose();
    isLoading.dispose();
    isSyncing.dispose();
    lastError.dispose();
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
      unawaited(startSync());
    }
  }

  Future<void> startSync() async {
    if (_currentPubkey == null) return;
    try {
      await _book.sync();
    } catch (error) {
      lastError.value = error.toString();
    }
  }

  Future<void> pull() async {
    if (isSyncing.value || _currentPubkey == null) return;
    isSyncing.value = true;
    lastError.value = null;
    try {
      await _book.refresh();
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
    return contacts.value
        .expand(_suggestionsFromContact)
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
