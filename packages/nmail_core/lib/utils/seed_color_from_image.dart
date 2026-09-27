import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// The source color [ColorScheme.fromImageProvider] would seed its scheme
/// with, so any palette style can then be built with [ColorScheme.fromSeed].
Future<Color> seedColorFromImage(ImageProvider provider) async {
  final image = await _resolve(
    ResizeImage(
      provider,
      width: 112,
      height: 112,
      policy: ResizeImagePolicy.fit,
    ),
  );
  try {
    final bytes = await image.toByteData();
    final argb = <int>[
      for (var i = 0; i + 3 < bytes!.lengthInBytes; i += 4)
        bytes.getUint8(i + 3) << 24 |
            bytes.getUint8(i) << 16 |
            bytes.getUint8(i + 1) << 8 |
            bytes.getUint8(i + 2),
    ];
    final quantized = await QuantizerCelebi().quantize(argb, 128);
    return Color(Score.score(quantized.colorToCount, desired: 1).first);
  } finally {
    image.dispose();
  }
}

Future<ui.Image> _resolve(ImageProvider provider) {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) {
      stream.removeListener(listener);
      completer.complete(info.image.clone());
      info.dispose();
    },
    onError: (error, stackTrace) {
      stream.removeListener(listener);
      completer.completeError(error, stackTrace);
    },
  );
  stream.addListener(listener);
  return completer.future;
}
