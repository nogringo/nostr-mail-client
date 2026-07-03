import 'package:nmail_core/utils/contact_birthday_utils.dart';

class AddressBookContactForm {
  final String? uid;
  final String displayName;
  final List<String> emails;
  final List<String> nostrPubkeys;
  final List<String> phones;
  final ContactBirthday? birthday;

  const AddressBookContactForm({
    this.uid,
    required this.displayName,
    this.emails = const [],
    this.nostrPubkeys = const [],
    this.phones = const [],
    this.birthday,
  });

  AddressBookContactForm copyWith({
    String? uid,
    String? displayName,
    List<String>? emails,
    List<String>? nostrPubkeys,
    List<String>? phones,
    ContactBirthday? birthday,
  }) {
    return AddressBookContactForm(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      emails: emails ?? this.emails,
      nostrPubkeys: nostrPubkeys ?? this.nostrPubkeys,
      phones: phones ?? this.phones,
      birthday: birthday ?? this.birthday,
    );
  }
}

class AddressBookValidationException implements Exception {
  final String message;

  const AddressBookValidationException(this.message);

  @override
  String toString() => message;
}
