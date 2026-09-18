import 'dart:typed_data';

const _signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
const _metadataChunks = {'eXIf', 'tEXt', 'zTXt', 'iTXt', 'tIME'};

bool isPng(Uint8List bytes) {
  if (bytes.length < _signature.length) return false;
  for (var i = 0; i < _signature.length; i++) {
    if (bytes[i] != _signature[i]) return false;
  }
  return true;
}

/// Drops the EXIF, text and timestamp chunks, along with any data after
/// `IEND`. Returns null when the structure is malformed.
Uint8List? stripPngMetadata(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final out = BytesBuilder(copy: false)
    ..add(Uint8List.sublistView(bytes, 0, _signature.length));
  var pos = _signature.length;

  while (pos + 12 <= bytes.length) {
    final end = pos + 12 + data.getUint32(pos);
    if (end > bytes.length) return null;
    final type = String.fromCharCodes(bytes, pos + 4, pos + 8);
    if (!_metadataChunks.contains(type)) {
      out.add(Uint8List.sublistView(bytes, pos, end));
    }
    if (type == 'IEND') return out.takeBytes();
    pos = end;
  }
  return null;
}
