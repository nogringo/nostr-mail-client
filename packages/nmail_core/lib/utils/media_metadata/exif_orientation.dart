import 'dart:typed_data';

const _orientationTag = 0x0112;

/// Reads the orientation (1 to 8) from a TIFF structure, as found in an EXIF
/// payload, or returns null when absent or malformed.
int? readTiffOrientation(Uint8List tiff) {
  if (tiff.length < 8) return null;
  final Endian endian;
  if (tiff[0] == 0x49 && tiff[1] == 0x49) {
    endian = Endian.little;
  } else if (tiff[0] == 0x4D && tiff[1] == 0x4D) {
    endian = Endian.big;
  } else {
    return null;
  }
  final data = ByteData.sublistView(tiff);
  final ifdOffset = data.getUint32(4, endian);
  if (ifdOffset + 2 > tiff.length) return null;
  final count = data.getUint16(ifdOffset, endian);
  for (var i = 0; i < count; i++) {
    final entry = ifdOffset + 2 + i * 12;
    if (entry + 12 > tiff.length) return null;
    if (data.getUint16(entry, endian) != _orientationTag) continue;
    final value = data.getUint16(entry + 8, endian);
    return value >= 1 && value <= 8 ? value : null;
  }
  return null;
}

/// A big-endian TIFF holding a single IFD0 entry: the orientation.
Uint8List buildOrientationTiff(int orientation) {
  final data = ByteData(26)
    ..setUint16(0, 0x4D4D)
    ..setUint16(2, 42)
    ..setUint32(4, 8)
    ..setUint16(8, 1)
    ..setUint16(10, _orientationTag)
    ..setUint16(12, 3)
    ..setUint32(14, 1)
    ..setUint16(18, orientation);
  return data.buffer.asUint8List();
}
