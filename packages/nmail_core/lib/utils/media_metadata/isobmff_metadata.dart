import 'dart:typed_data';

const _topLevelTypes = {'ftyp', 'moov', 'mdat', 'wide', 'free', 'skip'};
const _emptyXmp = '<x:xmpmeta xmlns:x="adobe:ns:meta/"/>';
const _xmpUuid = [
  0xBE, 0x7A, 0xCF, 0xCB, 0x97, 0xA9, 0x42, 0xE8, //
  0x9C, 0x71, 0x99, 0x94, 0x91, 0xE3, 0xAF, 0xAC,
];

/// Matches MP4, QuickTime, HEIF and AVIF files.
bool isIsobmff(Uint8List bytes) =>
    bytes.length >= 8 &&
    _topLevelTypes.contains(String.fromCharCodes(bytes, 4, 8));

/// Blanks the metadata of an ISO base media file without moving a byte, so
/// every offset into `mdat` stays valid: `udta`, `meta` and XMP `uuid` boxes
/// become `free` boxes, the header timestamps are zeroed, and the EXIF and XMP
/// items of a HEIF image are overwritten. Data after the last box is dropped.
/// Returns null when the structure is malformed.
Uint8List? stripIsobmffMetadata(Uint8List bytes) {
  final stripper = _Stripper(Uint8List.fromList(bytes));
  try {
    final end = stripper.walkTopLevel();
    if (end == 0) return null;
    return Uint8List.sublistView(stripper.bytes, 0, end);
  } on _MalformedBox {
    return null;
  }
}

class _MalformedBox implements Exception {}

class _Box {
  _Box(this.type, this.start, this.headerSize, this.end);

  final String type;
  final int start;
  final int headerSize;
  final int end;

  int get payload => start + headerSize;
}

class _Stripper {
  _Stripper(this.bytes) : data = ByteData.sublistView(bytes);

  final Uint8List bytes;
  final ByteData data;

  int walkTopLevel() {
    var pos = 0;
    while (true) {
      final box = _tryReadBox(pos, bytes.length);
      if (box == null) return pos;
      switch (box.type) {
        case 'moov':
          _walkContainer(box);
        case 'meta':
          _stripTopLevelMeta(box);
        case 'udta':
          _blank(box);
        case 'uuid':
          if (_isXmpUuid(box)) _blank(box);
      }
      pos = box.end;
    }
  }

  void _walkContainer(_Box container) {
    for (final box in _children(container.payload, container.end)) {
      switch (box.type) {
        case 'udta' || 'meta':
          _blank(box);
        case 'uuid':
          if (_isXmpUuid(box)) _blank(box);
        case 'mvhd' || 'tkhd' || 'mdhd':
          _zeroTimestamps(box);
        case 'trak' || 'mdia':
          _walkContainer(box);
      }
    }
  }

  /// A `pict` handler marks a HEIF image, whose top-level `meta` holds the
  /// image itself: only its metadata items are blanked.
  void _stripTopLevelMeta(_Box meta) {
    final children = _children(meta.payload + 4, meta.end).toList();
    final handler = children.where((box) => box.type == 'hdlr').firstOrNull;
    if (handler == null || _fourcc(handler.payload + 8) != 'pict') {
      _blank(meta);
      return;
    }

    final iinf = children.where((box) => box.type == 'iinf').firstOrNull;
    final iloc = children.where((box) => box.type == 'iloc').firstOrNull;
    if (iinf == null || iloc == null) return;
    final idat = children.where((box) => box.type == 'idat').firstOrNull;

    final targets = _metadataItems(iinf);
    for (final MapEntry(key: itemId, value: isExif) in targets.entries) {
      final extents = _itemExtents(iloc, idat, itemId);
      for (final (offset, length) in extents) {
        bytes.fillRange(offset, offset + length, isExif ? 0 : 0x20);
      }
      if (extents.isEmpty) continue;
      isExif ? _writeEmptyExif(extents.first) : _writeEmptyXmp(extents.first);
    }
  }

  /// Item ids of the EXIF (true) and XMP (false) items.
  Map<int, bool> _metadataItems(_Box iinf) {
    final version = _u8(iinf.payload);
    final entriesStart = iinf.payload + (version == 0 ? 6 : 8);
    final items = <int, bool>{};
    for (final infe in _children(entriesStart, iinf.end)) {
      if (infe.type != 'infe') continue;
      final version = _u8(infe.payload);
      var pos = infe.payload + 4;
      final int itemId;
      String? contentType;
      if (version >= 2) {
        itemId = version == 2 ? _u16(pos) : _u32(pos);
        pos += (version == 2 ? 2 : 4) + 2;
        final itemType = _fourcc(pos);
        pos = _skipCString(pos + 4, infe.end);
        if (itemType == 'Exif') {
          items[itemId] = true;
          continue;
        }
        if (itemType == 'mime') contentType = _cString(pos, infe.end);
      } else {
        itemId = _u16(pos);
        pos = _skipCString(pos + 4, infe.end);
        contentType = _cString(pos, infe.end);
      }
      if (contentType == 'application/rdf+xml') items[itemId] = false;
    }
    return items;
  }

  /// Absolute (offset, length) extents of [itemId], for items stored in the
  /// file or in `idat`.
  List<(int, int)> _itemExtents(_Box iloc, _Box? idat, int itemId) {
    final version = _u8(iloc.payload);
    var pos = iloc.payload + 4;
    final offsetSize = _u8(pos) >> 4;
    final lengthSize = _u8(pos) & 0x0F;
    final baseOffsetSize = _u8(pos + 1) >> 4;
    final indexSize = version == 1 || version == 2 ? _u8(pos + 1) & 0x0F : 0;
    pos += 2;
    final itemCount = version < 2 ? _u16(pos) : _u32(pos);
    pos += version < 2 ? 2 : 4;

    for (var i = 0; i < itemCount; i++) {
      final id = version < 2 ? _u16(pos) : _u32(pos);
      pos += version < 2 ? 2 : 4;
      var constructionMethod = 0;
      if (version == 1 || version == 2) {
        constructionMethod = _u16(pos) & 0x0F;
        pos += 2;
      }
      pos += 2;
      final baseOffset = _uint(pos, baseOffsetSize);
      pos += baseOffsetSize;
      final extentCount = _u16(pos);
      pos += 2;

      final extents = <(int, int)>[];
      for (var e = 0; e < extentCount; e++) {
        pos += indexSize;
        final extentOffset = _uint(pos, offsetSize);
        pos += offsetSize;
        final extentLength = _uint(pos, lengthSize);
        pos += lengthSize;
        if (id != itemId) continue;

        final int origin;
        final int limit;
        if (constructionMethod == 0) {
          origin = 0;
          limit = bytes.length;
        } else if (constructionMethod == 1 && idat != null) {
          origin = idat.payload;
          limit = idat.end;
        } else {
          continue;
        }
        final start = origin + baseOffset + extentOffset;
        final end = extentLength == 0 ? limit : start + extentLength;
        if (start < origin || end > limit || start >= end) continue;
        extents.add((start, end - start));
      }
      if (id == itemId) return extents;
    }
    return const [];
  }

  /// A zero TIFF header offset followed by a TIFF with an empty IFD0.
  void _writeEmptyExif((int, int) extent) {
    final (offset, length) = extent;
    if (length < 18) return;
    data
      ..setUint32(offset, 0)
      ..setUint16(offset + 4, 0x4D4D)
      ..setUint16(offset + 6, 42)
      ..setUint32(offset + 8, 8);
  }

  /// XMP packets may be padded with whitespace.
  void _writeEmptyXmp((int, int) extent) {
    final (offset, length) = extent;
    if (length < _emptyXmp.length) return;
    bytes.setRange(offset, offset + _emptyXmp.length, _emptyXmp.codeUnits);
  }

  void _zeroTimestamps(_Box box) {
    final width = _u8(box.payload) == 1 ? 8 : 4;
    final start = box.payload + 4;
    final end = start + 2 * width;
    if (end > box.end) throw _MalformedBox();
    bytes.fillRange(start, end, 0);
  }

  void _blank(_Box box) {
    bytes.setRange(box.start + 4, box.start + 8, 'free'.codeUnits);
    bytes.fillRange(box.payload, box.end, 0);
  }

  bool _isXmpUuid(_Box box) {
    if (box.payload + _xmpUuid.length > box.end) return false;
    for (var i = 0; i < _xmpUuid.length; i++) {
      if (bytes[box.payload + i] != _xmpUuid[i]) return false;
    }
    return true;
  }

  Iterable<_Box> _children(int start, int end) sync* {
    var pos = start;
    while (pos + 8 <= end) {
      final box = _tryReadBox(pos, end) ?? (throw _MalformedBox());
      yield box;
      pos = box.end;
    }
  }

  _Box? _tryReadBox(int pos, int limit) {
    if (pos + 8 > limit) return null;
    var size = _u32(pos);
    var headerSize = 8;
    if (size == 1) {
      if (pos + 16 > limit) return null;
      size = _uint(pos + 8, 8);
      headerSize = 16;
    } else if (size == 0) {
      size = limit - pos;
    }
    if (size < headerSize || pos + size > limit) return null;
    return _Box(_fourcc(pos + 4), pos, headerSize, pos + size);
  }

  int _skipCString(int pos, int end) {
    var i = pos;
    while (i < end && bytes[i] != 0) {
      i++;
    }
    return i + 1;
  }

  String? _cString(int pos, int end) {
    if (pos >= end) return null;
    final stop = _skipCString(pos, end) - 1;
    return String.fromCharCodes(bytes, pos, stop);
  }

  String _fourcc(int pos) {
    _check(pos, 4);
    return String.fromCharCodes(bytes, pos, pos + 4);
  }

  int _u8(int pos) {
    _check(pos, 1);
    return bytes[pos];
  }

  int _u16(int pos) {
    _check(pos, 2);
    return data.getUint16(pos);
  }

  int _u32(int pos) {
    _check(pos, 4);
    return data.getUint32(pos);
  }

  /// `getUint64` is unsupported when compiled to JavaScript.
  int _uint(int pos, int size) => switch (size) {
    0 => 0,
    4 => _u32(pos),
    8 => _u32(pos) * 0x100000000 + _u32(pos + 4),
    _ => throw _MalformedBox(),
  };

  void _check(int pos, int size) {
    if (pos < 0 || pos + size > bytes.length) throw _MalformedBox();
  }
}
