import 'package:nmail_core/services/address_book_service.dart';

/// No contacts and no storage behind them, for widgets that look a name up.
class EmptyAddressBookService extends AddressBookService {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  void onClose() {}
}
