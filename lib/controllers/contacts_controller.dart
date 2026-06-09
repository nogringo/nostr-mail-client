import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../app/routes/app_routes.dart';
import '../models/address_book_contact_form.dart';
import '../models/recipient.dart';
import '../services/address_book_service.dart';
import '../utils/address_book_vcard_mapper.dart';

class ContactsController extends GetxController {
  final addressBookService = Get.find<AddressBookService>();
  final queryController = TextEditingController();
  final query = ''.obs;
  final selectedUid = RxnString();
  final copiedVCardUid = RxnString();
  Timer? _copiedVCardTimer;

  List<AddressBookContact> get filteredContacts {
    final q = query.value.trim().toLowerCase();
    final list = addressBookService.contacts.where((contact) {
      if (q.isEmpty) return true;
      final index = contact.index;
      final haystack = [
        index.formattedName,
        ...index.emails,
        ...index.nostrIdentifiers,
        if (index.organization != null) index.organization!,
      ].join('\n').toLowerCase();
      return haystack.contains(q);
    }).toList();
    list.sort((a, b) {
      final byName = a.index.formattedName.toLowerCase().compareTo(
        b.index.formattedName.toLowerCase(),
      );
      if (byName != 0) return byName;
      return b.eventCreatedAt.compareTo(a.eventCreatedAt);
    });
    return list;
  }

  AddressBookContact? get selectedContact {
    final uid = selectedUid.value;
    if (uid == null) return null;
    return addressBookService.contacts.firstWhereOrNull(
      (contact) => contact.uid == uid,
    );
  }

  @override
  void onInit() {
    super.onInit();
    queryController.addListener(() => query.value = queryController.text);
    ever<List<AddressBookContact>>(addressBookService.contacts, (_) {
      _ensureSelection();
    });
    addressBookService.load(sync: true).then((_) => _ensureSelection());
  }

  @override
  void onClose() {
    _copiedVCardTimer?.cancel();
    queryController.dispose();
    super.onClose();
  }

  void select(AddressBookContact contact) {
    selectedUid.value = contact.uid;
  }

  Future<void> syncContacts() => addressBookService.fetchRecent();

  Future<void> retryBroadcasts() => addressBookService.retryBroadcasts();

  Future<void> save(
    AddressBookContactForm form, {
    AddressBookContact? existing,
  }) async {
    final saved = await addressBookService.saveContact(
      form,
      existing: existing,
    );
    selectedUid.value = saved.uid;
  }

  Future<void> deleteSelected() async {
    final contact = selectedContact;
    if (contact == null) return;
    await deleteContact(contact);
  }

  Future<void> deleteContact(AddressBookContact contact) async {
    await addressBookService.deleteContact(contact);
    if (selectedUid.value == contact.uid) {
      selectedUid.value = null;
    }
    _ensureSelection();
  }

  void copyVCard(AddressBookContact contact) {
    Clipboard.setData(ClipboardData(text: contact.vCard));
    copiedVCardUid.value = contact.uid;
    _copiedVCardTimer?.cancel();
    _copiedVCardTimer = Timer(const Duration(seconds: 2), () {
      if (copiedVCardUid.value == contact.uid) {
        copiedVCardUid.value = null;
      }
    });
  }

  void composeToEmail(BuildContext context, String email) {
    context.push(
      AppRoutes.compose,
      extra: {'recipient': Recipient(input: email, type: RecipientType.legacy)},
    );
  }

  void composeToPubkey(BuildContext context, String pubkey) {
    context.push(
      AppRoutes.compose,
      extra: {
        'recipient': Recipient(
          input: Nip19.encodePubKey(pubkey),
          pubkey: pubkey,
          type: RecipientType.nostr,
        ),
      },
    );
  }

  AddressBookContactForm formFor(AddressBookContact contact) {
    return AddressBookVCardMapper.formFromContact(contact);
  }

  void _ensureSelection() {
    final current = selectedUid.value;
    final visible = filteredContacts;
    if (visible.isEmpty) {
      selectedUid.value = null;
      return;
    }
    if (current == null || !visible.any((contact) => contact.uid == current)) {
      selectedUid.value = visible.first.uid;
    }
  }
}
