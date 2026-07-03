import 'package:flutter/services.dart';

import '../utils/platform_helper.dart';

/// Copies text to the clipboard while hiding it from the system clipboard
/// preview (the overlay Android 13+ shows in the bottom corner after a copy).
///
/// On Android the clip is flagged with `EXTRA_IS_SENSITIVE` via a native
/// method channel so the preview shows dots instead of the content (like
/// password managers). On every other platform it falls back to the regular
/// [Clipboard.setData].
abstract class SensitiveClipboard {
  static const _platform = MethodChannel('app.nostrmail.client/native');

  static Future<void> copy(String text, {String label = 'text'}) async {
    if (PlatformHelper.isAndroid) {
      try {
        await _platform.invokeMethod('copySensitive', {
          'text': text,
          'label': label,
        });
        return;
      } on PlatformException {
        // Fall back to the standard clipboard if the native call fails.
      }
    }
    await Clipboard.setData(ClipboardData(text: text));
  }
}
