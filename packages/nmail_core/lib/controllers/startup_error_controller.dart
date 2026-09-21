import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

class StartupErrorController extends GetxController {
  bool hasCopied = false;
  Timer? _resetTimer;

  Future<void> copyDetails(String details) async {
    await Clipboard.setData(ClipboardData(text: details));
    hasCopied = true;
    update();

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      hasCopied = false;
      update();
    });
  }

  @override
  void onClose() {
    _resetTimer?.cancel();
    super.onClose();
  }
}
