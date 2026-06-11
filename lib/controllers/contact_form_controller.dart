import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import '../models/address_book_contact_form.dart';
import 'contacts_controller.dart';

class ContactFormController extends GetxController {
  final AddressBookContact? contact;
  final AddressBookContactForm? initialForm;

  ContactFormController({this.contact, this.initialForm});

  late final TextEditingController nameController;
  late final TextEditingController emailInputController;
  late final TextEditingController nostrInputController;
  late final TextEditingController phoneInputController;
  late final TextEditingController birthdayController;

  final isSaving = false.obs;
  final canSave = false.obs;
  final error = RxnString();
  final emails = <String>[].obs;
  final nostrIdentifiers = <String>[].obs;
  final phones = <String>[].obs;
  final List<Worker> _workers = [];

  ContactsController get _contactsController => Get.find<ContactsController>();

  bool get isEditing => contact != null;

  @override
  void onInit() {
    super.onInit();
    final form =
        initialForm ??
        (contact == null ? null : _contactsController.formFor(contact!));
    nameController = TextEditingController(text: form?.displayName ?? '');
    emailInputController = TextEditingController();
    nostrInputController = TextEditingController();
    phoneInputController = TextEditingController();
    birthdayController = TextEditingController(text: form?.birthday ?? '');
    emails.assignAll(form?.emails ?? const []);
    nostrIdentifiers.assignAll(
      form?.nostrPubkeys.map(Nip19.encodePubKey) ?? const [],
    );
    phones.assignAll(form?.phones ?? const []);

    nameController.addListener(_refreshCanSave);
    emailInputController.addListener(_refreshCanSave);
    phoneInputController.addListener(_refreshCanSave);
    nostrInputController.addListener(_refreshCanSave);
    _workers.addAll([
      ever(emails, (_) => _refreshCanSave()),
      ever(phones, (_) => _refreshCanSave()),
      ever(nostrIdentifiers, (_) => _refreshCanSave()),
    ]);
    _refreshCanSave();
  }

  @override
  void onClose() {
    for (final worker in _workers) {
      worker.dispose();
    }
    nameController.dispose();
    emailInputController.dispose();
    nostrInputController.dispose();
    phoneInputController.dispose();
    birthdayController.dispose();
    super.onClose();
  }

  void _refreshCanSave() {
    canSave.value = _hasContent();
  }

  bool _hasContent() {
    if (nameController.text.trim().isNotEmpty) return true;
    if (emails.isNotEmpty || phones.isNotEmpty || nostrIdentifiers.isNotEmpty) {
      return true;
    }
    return _pendingMethods(emailInputController).isNotEmpty ||
        _pendingMethods(phoneInputController).isNotEmpty ||
        _pendingMethods(nostrInputController).isNotEmpty;
  }

  void addEmailFromInput() {
    _addMethod(emailInputController, emails);
  }

  void addPhoneFromInput() {
    _addMethod(phoneInputController, phones);
  }

  Future<bool> addNostrFromInput() async {
    final pending = _pendingMethods(nostrInputController);
    if (pending.isEmpty) return true;

    final existing = nostrIdentifiers
        .map((value) => value.toLowerCase())
        .toSet();
    final resolved = <String>[];
    for (final value in pending) {
      final pubkey = await _contactsController.addressBookService
          .resolveNostrIdentifier(value);
      if (pubkey == null) {
        error.value = 'Invalid Nostr identifier: $value';
        return false;
      }
      if (existing.add(pubkey.toLowerCase())) {
        resolved.add(pubkey);
      }
    }

    nostrIdentifiers.addAll(resolved);
    nostrInputController.clear();
    error.value = null;
    return true;
  }

  void removeEmail(String email) {
    emails.remove(email);
  }

  void removeNostrIdentifier(String identifier) {
    nostrIdentifiers.remove(identifier);
  }

  void removePhone(String phone) {
    phones.remove(phone);
  }

  Future<bool> save() async {
    if (isSaving.value) return false;
    isSaving.value = true;
    error.value = null;
    try {
      _addMethod(emailInputController, emails);
      _addMethod(phoneInputController, phones);
      if (!await addNostrFromInput()) return false;
      await _contactsController.save(
        AddressBookContactForm(
          uid: contact?.uid ?? initialForm?.uid,
          displayName: nameController.text,
          emails: emails.toList(),
          nostrPubkeys: nostrIdentifiers.toList(),
          phones: phones.toList(),
          birthday: birthdayController.text,
        ),
        existing: contact,
      );
      return true;
    } catch (saveError) {
      error.value = saveError.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void _addMethod(TextEditingController input, RxList<String> values) {
    final pending = _pendingMethods(input);
    if (pending.isEmpty) return;

    final existing = values.map((value) => value.toLowerCase()).toSet();
    for (final value in pending) {
      if (existing.add(value.toLowerCase())) {
        values.add(value);
      }
    }
    input.clear();
  }

  List<String> _pendingMethods(TextEditingController input) {
    return input.text
        .split(RegExp(r'[\s,;]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }
}
