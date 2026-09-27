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
