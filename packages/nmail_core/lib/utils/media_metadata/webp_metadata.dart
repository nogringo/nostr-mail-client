import 'dart:typed_data';

const _exifFlag = 0x08;
const _xmpFlag = 0x04;

bool isWebp(Uint8List bytes) =>
    bytes.length >= 12 &&
    String.fromCharCodes(bytes, 0, 4) == 'RIFF' &&
    String.fromCharCodes(bytes, 8, 12) == 'WEBP';

/// Drops the `EXIF` and `XMP ` chunks and clears their flags in `VP8X`.
/// Returns null when the structure is malformed.
Uint8List? stripWebpMetadata(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final riffEnd = 8 + data.getUint32(4, Endian.little);
  final end = riffEnd < bytes.length ? riffEnd : bytes.length;
  final chunks = BytesBuilder(copy: false);
  var pos = 12;

  while (pos + 8 <= end) {
    final size = data.getUint32(pos + 4, Endian.little);
    final chunkEnd = pos + 8 + size + (size & 1);
    if (chunkEnd > end) return null;
    final type = String.fromCharCodes(bytes, pos, pos + 4);
    if (type == 'VP8X' && size > 0) {
      final chunk = Uint8List.fromList(
        Uint8List.sublistView(bytes, pos, chunkEnd),
      );
      chunk[8] &= ~(_exifFlag | _xmpFlag);
      chunks.add(chunk);
    } else if (type != 'EXIF' && type != 'XMP ') {
      chunks.add(Uint8List.sublistView(bytes, pos, chunkEnd));
    }
    pos = chunkEnd;
  }

  final body = chunks.takeBytes();
  final header = ByteData(12)
    ..setUint32(0, 0x52494646)
    ..setUint32(4, 4 + body.length, Endian.little)
    ..setUint32(8, 0x57454250);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(body))
      .takeBytes();
}
