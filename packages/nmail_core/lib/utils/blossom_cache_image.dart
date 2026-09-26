import 'dart:ui' as ui;

import 'package:blossom_cache/blossom_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

/// Decodes an image from the local Blossom cache, never from a server.
class BlossomCacheImage extends ImageProvider<BlossomCacheImage> {
  const BlossomCacheImage(this.sha256);

  final String sha256;

  @override
  Future<BlossomCacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<BlossomCacheImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    BlossomCacheImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1,
      debugLabel: 'BlossomCacheImage(${key.sha256})',
    );
  }

  Future<ui.Codec> _loadAsync(
    BlossomCacheImage key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await Get.find<BlossomCache>().get(key.sha256);
    if (bytes == null) {
      throw StateError('${key.sha256} is not in the Blossom cache');
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is BlossomCacheImage && other.sha256 == sha256;

  @override
  int get hashCode => sha256.hashCode;
}
