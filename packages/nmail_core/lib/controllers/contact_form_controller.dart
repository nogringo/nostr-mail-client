import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_address_book/nostr_address_book.dart';

import 'package:nmail_core/models/address_book_contact_form.dart';
import 'package:nmail_core/utils/contact_birthday_utils.dart';
import 'contacts_controller.dart';

class ContactFormController extends ChangeNotifier {
  final AddressBookContact? contact;
  final AddressBookContactForm? initialForm;

  ContactFormController({this.contact, this.initialForm}) {
    final form =
        initialForm ??
        (contact == null ? null : _contactsController.formFor(contact!));
    nameController = TextEditingController(text: form?.displayName ?? '');
    emailInputController = TextEditingController();
    nostrInputController = TextEditingController();
    phoneInputController = TextEditingController();
    final birthday = form?.birthday;
    _birthdayMonth = birthday?.month;
    _birthdayDay = birthday?.day;
    birthdayExpanded = birthday != null;
    birthdayYearController = TextEditingController(
      text: birthday?.year?.toString() ?? '',
    );
    emails.addAll(form?.emails ?? const []);
    nostrIdentifiers.addAll(
      form?.nostrPubkeys.map(Nip19.encodePubKey) ?? const [],
    );
    phones.addAll(form?.phones ?? const []);

    nameController.addListener(notifyListeners);
    emailInputController.addListener(notifyListeners);
    phoneInputController.addListener(notifyListeners);
    nostrInputController.addListener(notifyListeners);
  }

  late final TextEditingController nameController;
  late final TextEditingController emailInputController;
  late final TextEditingController nostrInputController;
  late final TextEditingController phoneInputController;
  late final TextEditingController birthdayYearController;

  int? get birthdayMonth => _birthdayMonth;
  set birthdayMonth(int? value) {
    _birthdayMonth = value;
    notifyListeners();
  }

  int? get birthdayDay => _birthdayDay;
  set birthdayDay(int? value) {
    _birthdayDay = value;
    notifyListeners();
  }

  int? _birthdayMonth;
  int? _birthdayDay;
  bool birthdayExpanded = false;

  bool isSaving = false;
  String? error;
  final List<String> emails = [];
  final List<String> nostrIdentifiers = [];
  final List<String> phones = [];
  bool _isDisposed = false;

  ContactsController get _contactsController => GetIt.I<ContactsController>();

  bool get isEditing => contact != null;

  bool get canSave => _hasContent();

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    emailInputController.dispose();
    nostrInputController.dispose();
    phoneInputController.dispose();
    birthdayYearController.dispose();
    super.dispose();
  }

  void expandBirthday() {
    birthdayExpanded = true;
    notifyListeners();
  }

  void clearBirthday() {
    _birthdayMonth = null;
    _birthdayDay = null;
    birthdayYearController.clear();
    birthdayExpanded = false;
    notifyListeners();
  }

  /// Builds the birthday from the day/month/year inputs.
  ///
  /// Returns `null` when day or month is missing. The year is only applied when
  /// it is a full 4-digit number, otherwise the birthday is saved without a
  /// year.
  ContactBirthday? _birthdayValue() {
    final month = _birthdayMonth;
    final day = _birthdayDay;
    if (month == null || day == null) return null;
    final yearText = birthdayYearController.text.trim();
    final year = yearText.length == 4 ? int.tryParse(yearText) : null;
    return ContactBirthday(year: year, month: month, day: day);
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
      if (_isDisposed) return false;
      if (pubkey == null) {
        error = 'Invalid Nostr identifier: $value';
        notifyListeners();
        return false;
      }
      if (existing.add(pubkey.toLowerCase())) {
        resolved.add(pubkey);
      }
    }

    nostrIdentifiers.addAll(resolved);
    nostrInputController.clear();
    error = null;
    notifyListeners();
    return true;
  }

  void removeEmail(String email) {
    emails.remove(email);
    notifyListeners();
  }

  void removeNostrIdentifier(String identifier) {
    nostrIdentifiers.remove(identifier);
    notifyListeners();
  }

  void removePhone(String phone) {
    phones.remove(phone);
    notifyListeners();
  }

  Future<bool> save() async {
    if (isSaving) return false;
    isSaving = true;
    error = null;
    notifyListeners();
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
          birthday: _birthdayValue(),
        ),
        existing: contact,
      );
      return true;
    } catch (saveError) {
      error = saveError.toString();
      return false;
    } finally {
      if (!_isDisposed) {
        isSaving = false;
        notifyListeners();
      }
    }
  }

  void _addMethod(TextEditingController input, List<String> values) {
    final pending = _pendingMethods(input);
    if (pending.isEmpty) return;

    final existing = values.map((value) => value.toLowerCase()).toSet();
    for (final value in pending) {
      if (existing.add(value.toLowerCase())) {
        values.add(value);
      }
    }
    input.clear();
    notifyListeners();
  }

  List<String> _pendingMethods(TextEditingController input) {
    return input.text
        .split(RegExp(r'[\s,;]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }
}
