class AddressBookContactForm {
  final String? uid;
  final String displayName;
  final List<String> emails;
  final List<String> nostrPubkeys;

  const AddressBookContactForm({
    this.uid,
    required this.displayName,
    this.emails = const [],
    this.nostrPubkeys = const [],
  });

  AddressBookContactForm copyWith({
    String? uid,
    String? displayName,
    List<String>? emails,
    List<String>? nostrPubkeys,
  }) {
    return AddressBookContactForm(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      emails: emails ?? this.emails,
      nostrPubkeys: nostrPubkeys ?? this.nostrPubkeys,
    );
  }
}

class AddressBookValidationException implements Exception {
  final String message;

  const AddressBookValidationException(this.message);

  @override
  String toString() => message;
}
