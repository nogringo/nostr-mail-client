import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// On the web the browser pastes into Flutter's hidden text field, which
/// drops images, so pasted image files are read from the DOM event instead.
StreamSubscription<void>? listenToBrowserImagePaste({
  required bool Function() accepts,
  required void Function(Uint8List bytes) onImage,
}) {
  return web.EventStreamProviders.pasteEvent
      .forTarget(web.document, useCapture: true)
      .listen((event) {
        final files = event.clipboardData?.files;
        if (files == null || !accepts()) return;

        final images = [
          for (var i = 0; i < files.length; i++)
            if (files.item(i) case final file?
                when file.type.startsWith('image/'))
              file,
        ];
        if (images.isEmpty) return;

        event.preventDefault();
        for (final image in images) {
          image.arrayBuffer().toDart.then(
            (buffer) => onImage(buffer.toDart.asUint8List()),
          );
        }
      });
}

/// Reads through the async Clipboard API, which asks for permission.
Future<Uint8List?> readBrowserClipboardImage() async {
  final items = (await web.window.navigator.clipboard.read().toDart).toDart;
  for (final item in items) {
    for (final type in item.types.toDart) {
      if (!type.toDart.startsWith('image/')) continue;
      final blob = await item.getType(type.toDart).toDart;
      return (await blob.arrayBuffer().toDart).toDart.asUint8List();
    }
  }
  return null;
}
