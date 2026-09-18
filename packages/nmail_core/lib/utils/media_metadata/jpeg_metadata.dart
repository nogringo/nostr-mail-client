import 'dart:convert';
import 'dart:typed_data';

import 'exif_orientation.dart';

const _app0 = 0xE0;
const _app1 = 0xE1;
const _app2 = 0xE2;
const _app14 = 0xEE;
const _app15 = 0xEF;
const _comment = 0xFE;
const _startOfScan = 0xDA;
const _endOfImage = 0xD9;

final _exifHeader = ascii.encode('Exif\x00\x00');
final _iccHeader = ascii.encode('ICC_PROFILE\x00');

bool isJpeg(Uint8List bytes) =>
    bytes.length >= 3 &&
    bytes[0] == 0xFF &&
    bytes[1] == 0xD8 &&
    bytes[2] == 0xFF;

/// Keeps the segments needed to render the image (JFIF, ICC profile, Adobe)
/// and drops every other APPn and COM segment, along with any data after the
/// end of the image. A non-default EXIF orientation survives as a minimal
/// EXIF segment. Returns null when the structure is malformed.
Uint8List? stripJpegMetadata(Uint8List bytes) {
  final out = BytesBuilder(copy: false)
    ..add(Uint8List.sublistView(bytes, 0, 2));
  var pos = 2;

  while (true) {
    if (pos >= bytes.length || bytes[pos] != 0xFF) return null;
    while (pos < bytes.length && bytes[pos] == 0xFF) {
      pos++;
    }
    if (pos >= bytes.length) return null;
    final marker = bytes[pos++];

    if (marker == _endOfImage) {
      out.add(const [0xFF, _endOfImage]);
      return out.takeBytes();
    }
    if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) {
      out.add([0xFF, marker]);
      continue;
    }

    if (pos + 2 > bytes.length) return null;
    final length = (bytes[pos] << 8) | bytes[pos + 1];
    if (length < 2 || pos + length > bytes.length) return null;
    final payload = Uint8List.sublistView(bytes, pos + 2, pos + length);

    if (marker == _app1 && _startsWith(payload, _exifHeader)) {
      final orientation = readTiffOrientation(
        Uint8List.sublistView(payload, _exifHeader.length),
      );
      if (orientation != null && orientation != 1) {
        out.add(_orientationSegment(orientation));
      }
    } else if (_keepSegment(marker, payload)) {
      out
        ..add([0xFF, marker])
        ..add(Uint8List.sublistView(bytes, pos, pos + length));
    }
    pos += length;

    if (marker == _startOfScan) {
      final scanEnd = _entropyDataEnd(bytes, pos);
      out.add(Uint8List.sublistView(bytes, pos, scanEnd));
      if (scanEnd >= bytes.length) return out.takeBytes();
      pos = scanEnd;
    }
  }
}

bool _keepSegment(int marker, Uint8List payload) {
  if (marker == _comment) return false;
  if (marker < _app0 || marker > _app15) return true;
  return marker == _app0 ||
      marker == _app14 ||
      (marker == _app2 && _startsWith(payload, _iccHeader));
}

/// Index of the first marker after entropy-coded data, where `FF 00` is a
/// stuffed byte and `FF D0` to `FF D7` are restart markers.
int _entropyDataEnd(Uint8List bytes, int start) {
  var i = start;
  while (i + 1 < bytes.length) {
    if (bytes[i] == 0xFF) {
      final next = bytes[i + 1];
      final isData = next == 0x00 || (next >= 0xD0 && next <= 0xD7);
      if (!isData && next != 0xFF) return i;
    }
    i++;
  }
  return bytes.length;
}

Uint8List _orientationSegment(int orientation) {
  final tiff = buildOrientationTiff(orientation);
  final length = 2 + _exifHeader.length + tiff.length;
  return Uint8List.fromList([
    0xFF,
    _app1,
    length >> 8,
    length & 0xFF,
    ..._exifHeader,
    ...tiff,
  ]);
}

bool _startsWith(Uint8List bytes, List<int> prefix) {
  if (bytes.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[i] != prefix[i]) return false;
  }
  return true;
}
