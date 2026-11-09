import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/address_book_contact_form.dart';

extension AddressBookValidationMessage on AddressBookValidationException {
  String localizedMessage(AppLocalizations l) => switch (error) {
    AddressBookValidationError.nameRequired => l.contactsNameRequired,
    AddressBookValidationError.invalidEmail => l.contactsInvalidEmail(value),
    AddressBookValidationError.invalidPhone => l.contactsInvalidPhone(value),
    AddressBookValidationError.invalidNostrIdentifier =>
      l.contactsInvalidNostrIdentifier(value),
  };
}
