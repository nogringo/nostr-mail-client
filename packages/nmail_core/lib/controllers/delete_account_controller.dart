import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';

/// Drives the delete-account confirmation dialog: the typed confirmation, the
/// signing step, and the refusal it can end on.
class DeleteAccountController extends GetxController {
  final confirmation = TextEditingController();

  bool isDeleting = false;
  bool hasFailed = false;

  @override
  void onInit() {
    super.onInit();
    confirmation.addListener(update);
  }

  @override
  void onClose() {
    confirmation.dispose();
    super.onClose();
  }

  bool confirms(String word) =>
      confirmation.text.trim().toUpperCase() == word.toUpperCase();

  /// Returns the id of the queued request to vanish, or null when the signer
  /// refused, in which case nothing was deleted.
  Future<String?> delete() async {
    if (isDeleting) return null;
    isDeleting = true;
    hasFailed = false;
    update();

    try {
      final request = await Get.find<AuthController>().deleteAccount();
      return request.id;
    } catch (_) {
      if (isClosed) return null;
      isDeleting = false;
      hasFailed = true;
      update();
      return null;
    }
  }
}
