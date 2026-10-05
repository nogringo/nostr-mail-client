import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class StartupErrorController extends ChangeNotifier {
  bool hasCopied = false;
  Timer? _resetTimer;

  Future<void> copyDetails(String details) async {
    await Clipboard.setData(ClipboardData(text: details));
    hasCopied = true;
    notifyListeners();

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      hasCopied = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
}
