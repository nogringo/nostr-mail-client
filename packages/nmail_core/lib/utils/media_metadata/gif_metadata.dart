import 'dart:typed_data';

const _extensionIntroducer = 0x21;
const _imageSeparator = 0x2C;
const _trailer = 0x3B;
const _commentLabel = 0xFE;
const _applicationLabel = 0xFF;

/// Application extensions that affect rendering: looping and color profile.
const _keptApplications = {'NETSCAPE2.0', 'ANIMEXTS1.0', 'ICCRGBG1012'};

bool isGif(Uint8List bytes) {
  if (bytes.length < 6) return false;
  final signature = String.fromCharCodes(bytes, 0, 6);
  return signature == 'GIF87a' || signature == 'GIF89a';
}

/// Drops the comment extensions and the application extensions other than
/// looping and color profile (XMP among them), along with any data after the
/// trailer. Returns null when the structure is malformed.
Uint8List? stripGifMetadata(Uint8List bytes) {
  if (bytes.length < 13) return null;
  var pos = 13 + _colorTableSize(bytes[10]);
  if (pos > bytes.length) return null;
  final out = BytesBuilder(copy: false)
    ..add(Uint8List.sublistView(bytes, 0, pos));

  while (pos < bytes.length) {
    final start = pos;
    final introducer = bytes[pos];
    if (introducer == _trailer) {
      out.addByte(_trailer);
      return out.takeBytes();
    }

    var keep = true;
    if (introducer == _extensionIntroducer) {
      if (pos + 2 > bytes.length) return null;
      final label = bytes[pos + 1];
      pos += 2;
      if (label == _commentLabel) {
        keep = false;
      } else if (label == _applicationLabel) {
        keep = _keptApplications.contains(_applicationId(bytes, pos));
      }
    } else if (introducer == _imageSeparator) {
      if (pos + 10 > bytes.length) return null;
      pos += 10 + _colorTableSize(bytes[pos + 9]) + 1;
    } else {
      return null;
    }

    final end = _skipSubBlocks(bytes, pos);
    if (end == null) return null;
    if (keep) out.add(Uint8List.sublistView(bytes, start, end));
    pos = end;
  }
  return null;
}

int _colorTableSize(int packed) =>
    packed & 0x80 == 0 ? 0 : 3 * (1 << ((packed & 0x07) + 1));

String? _applicationId(Uint8List bytes, int pos) {
  if (pos + 12 > bytes.length || bytes[pos] != 11) return null;
  return String.fromCharCodes(bytes, pos + 1, pos + 12);
}

int? _skipSubBlocks(Uint8List bytes, int start) {
  var pos = start;
  while (pos < bytes.length) {
    final size = bytes[pos];
    pos += 1 + size;
    if (size == 0) return pos <= bytes.length ? pos : null;
  }
  return null;
}
