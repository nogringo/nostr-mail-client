import 'dart:typed_data';

const _ebmlId = 0x1A45DFA3;
const _segmentId = 0x18538067;
const _seekHeadId = 0x114D9B74;
const _seekId = 0x4DBB;
const _seekIdId = 0x53AB;
const _infoId = 0x1549A966;
const _dateUtcId = 0x4461;
const _titleId = 0x7BA9;
const _tagsId = 0x1254C367;
const _clusterId = 0x1F43B675;
const _crc32Id = 0xBF;
const _voidId = 0xEC;

/// Elements that end a Cluster of unknown size.
const _segmentLevelIds = {
  _ebmlId,
  _segmentId,
  _seekHeadId,
  _infoId,
  0x1654AE6B,
  0x1C53BB6B,
  _clusterId,
  _tagsId,
  0x1941A469,
  0x1043A770,
};

bool isMatroska(Uint8List bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x1A &&
    bytes[1] == 0x45 &&
    bytes[2] == 0xDF &&
    bytes[3] == 0xA3;

/// Blanks the metadata of a WebM or Matroska file without moving a byte:
/// `Tags`, the `DateUTC` and `Title` of `Info`, and the `SeekHead` entry
/// pointing to `Tags` become `Void` elements. The `CRC-32` of each edited
/// element is voided too. Returns null when the structure is malformed.
Uint8List? stripMatroskaMetadata(Uint8List bytes) {
  final stripper = _Stripper(Uint8List.fromList(bytes));
  try {
    stripper.walk();
    return stripper.bytes;
  } on _MalformedElement {
    return null;
  }
}

class _MalformedElement implements Exception {}

class _Element {
  _Element(this.id, this.start, this.dataStart, this.end);

  final int id;
  final int start;
  final int dataStart;

  /// Null for an element of unknown size.
  final int? end;
}

class _Stripper {
  _Stripper(this.bytes);

  final Uint8List bytes;

  void walk() {
    var pos = 0;
    while (pos < bytes.length) {
      final element = _read(pos, bytes.length);
      if (element.id == _segmentId) {
        _walkSegment(element.dataStart, element.end ?? bytes.length);
      }
      pos = element.end ?? bytes.length;
    }
  }

  void _walkSegment(int start, int end) {
    var pos = start;
    while (pos < end) {
      final element = _read(pos, end);
      final elementEnd = element.end;
      if (elementEnd == null) {
        if (element.id != _clusterId) throw _MalformedElement();
        pos = _unknownClusterEnd(element.dataStart, end);
        continue;
      }
      switch (element.id) {
        case _tagsId:
          _void(element);
        case _infoId:
          _stripChildren(element, (child) {
            return child.id == _dateUtcId || child.id == _titleId;
          });
        case _seekHeadId:
          _stripChildren(element, _isSeekToTags);
      }
      pos = elementEnd;
    }
  }

  void _stripChildren(_Element parent, bool Function(_Element) isMetadata) {
    final children = _children(parent.dataStart, parent.end!).toList();
    final metadata = children.where(isMetadata).toList();
    if (metadata.isEmpty) return;
    metadata.forEach(_void);
    children.where((child) => child.id == _crc32Id).forEach(_void);
  }

  bool _isSeekToTags(_Element seek) {
    if (seek.id != _seekId) return false;
    for (final child in _children(seek.dataStart, seek.end!)) {
      if (child.id != _seekIdId || child.end! - child.dataStart != 4) continue;
      final target = ByteData.sublistView(bytes).getUint32(child.dataStart);
      if (target == _tagsId) return true;
    }
    return false;
  }

  int _unknownClusterEnd(int start, int limit) {
    var pos = start;
    while (pos < limit) {
      final (id, _) = _readId(pos);
      if (_segmentLevelIds.contains(id)) return pos;
      pos = _read(pos, limit).end ?? (throw _MalformedElement());
    }
    return limit;
  }

  Iterable<_Element> _children(int start, int end) sync* {
    var pos = start;
    while (pos < end) {
      final element = _read(pos, end);
      yield element;
      pos = element.end ?? (throw _MalformedElement());
    }
  }

  /// Rewrites [element] as a `Void` of the same total length.
  void _void(_Element element) {
    final total = element.end! - element.start;
    final sizeLength = total - 1 < 8 ? total - 1 : 8;
    var dataLength = total - 1 - sizeLength;
    bytes[element.start] = _voidId;
    for (var i = sizeLength; i >= 1; i--) {
      bytes[element.start + i] = dataLength & 0xFF;
      dataLength = dataLength ~/ 256;
    }
    bytes[element.start + 1] |= 0x80 >> (sizeLength - 1);
    bytes.fillRange(element.start + 1 + sizeLength, element.end!, 0);
  }

  _Element _read(int pos, int limit) {
    final (id, idLength) = _readId(pos);
    final sizePos = pos + idLength;
    final sizeLength = _vintLength(sizePos);
    var size = bytes[sizePos] & (0xFF >> sizeLength);
    var unknown = size == 0xFF >> sizeLength;
    for (var i = 1; i < sizeLength; i++) {
      final byte = bytes[sizePos + i];
      size = size * 256 + byte;
      unknown = unknown && byte == 0xFF;
    }
    final dataStart = sizePos + sizeLength;
    if (unknown) return _Element(id, pos, dataStart, null);
    final end = dataStart + size;
    if (end > limit) throw _MalformedElement();
    return _Element(id, pos, dataStart, end);
  }

  (int, int) _readId(int pos) {
    final length = _vintLength(pos);
    if (length > 4) throw _MalformedElement();
    var id = 0;
    for (var i = 0; i < length; i++) {
      id = (id << 8) | bytes[pos + i];
    }
    return (id, length);
  }

  int _vintLength(int pos) {
    if (pos >= bytes.length || bytes[pos] == 0) throw _MalformedElement();
    var length = 1;
    while (bytes[pos] & (0x80 >> (length - 1)) == 0) {
      length++;
    }
    if (pos + length > bytes.length) throw _MalformedElement();
    return length;
  }
}
