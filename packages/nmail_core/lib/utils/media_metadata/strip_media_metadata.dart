import 'dart:typed_data';

import 'gif_metadata.dart';
import 'isobmff_metadata.dart';
import 'jpeg_metadata.dart';
import 'matroska_metadata.dart';
import 'png_metadata.dart';
import 'webp_metadata.dart';

/// Removes the metadata (capture date, location, device, etc.) of a JPEG,
/// PNG, WebP, GIF, HEIF, AVIF, MP4, QuickTime, WebM or Matroska file without
/// re-encoding it.
/// Returns [bytes] unchanged for any other format or a malformed file.
Uint8List stripMediaMetadata(Uint8List bytes) {
  final Uint8List? stripped;
  if (isJpeg(bytes)) {
    stripped = stripJpegMetadata(bytes);
  } else if (isPng(bytes)) {
    stripped = stripPngMetadata(bytes);
  } else if (isWebp(bytes)) {
    stripped = stripWebpMetadata(bytes);
  } else if (isGif(bytes)) {
    stripped = stripGifMetadata(bytes);
  } else if (isIsobmff(bytes)) {
    stripped = stripIsobmffMetadata(bytes);
  } else if (isMatroska(bytes)) {
    stripped = stripMatroskaMetadata(bytes);
  } else {
    stripped = null;
  }
  return stripped ?? bytes;
}
