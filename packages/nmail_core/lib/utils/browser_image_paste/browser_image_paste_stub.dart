import 'dart:async';
import 'dart:typed_data';

StreamSubscription<void>? listenToBrowserImagePaste({
  required bool Function() accepts,
  required void Function(Uint8List bytes) onImage,
}) => null;
