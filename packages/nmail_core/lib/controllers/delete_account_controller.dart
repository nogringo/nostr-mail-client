import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'auth_controller.dart';

/// Drives the delete-account confirmation dialog: the typed confirmation, the
/// signing step, and the refusal it can end on.
class DeleteAccountController extends ChangeNotifier {
  DeleteAccountController() {
    confirmation.addListener(notifyListeners);
  }

  final confirmation = TextEditingController();

  bool isDeleting = false;
  bool hasFailed = false;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    confirmation.dispose();
    super.dispose();
  }

  bool confirms(String word) =>
      confirmation.text.trim().toUpperCase() == word.toUpperCase();

  /// Returns the id of the queued request to vanish, or null when the signer
  /// refused, in which case nothing was deleted.
  Future<String?> delete() async {
    if (isDeleting) return null;
    isDeleting = true;
    hasFailed = false;
    notifyListeners();

    try {
      final request = await GetIt.I<AuthController>().deleteAccount();
      return request.id;
    } catch (_) {
      if (_isDisposed) return null;
      isDeleting = false;
      hasFailed = true;
      notifyListeners();
      return null;
    }
  }
}
