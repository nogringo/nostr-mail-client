import '../utils/contact_birthday_utils.dart';

class AddressBookContactForm {
  final String? uid;
  final String displayName;
  final String organization;
  final String jobTitle;
  final String note;
  final List<String> emails;
  final List<String> nostrPubkeys;
  final List<String> phones;
  final ContactBirthday? birthday;

  const AddressBookContactForm({
    this.uid,
    required this.displayName,
    this.organization = '',
    this.jobTitle = '',
    this.note = '',
    this.emails = const [],
    this.nostrPubkeys = const [],
    this.phones = const [],
    this.birthday,
  });

  AddressBookContactForm copyWith({
    String? uid,
    String? displayName,
    String? organization,
    String? jobTitle,
    String? note,
    List<String>? emails,
    List<String>? nostrPubkeys,
    List<String>? phones,
    ContactBirthday? birthday,
  }) {
    return AddressBookContactForm(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      organization: organization ?? this.organization,
      jobTitle: jobTitle ?? this.jobTitle,
      note: note ?? this.note,
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
