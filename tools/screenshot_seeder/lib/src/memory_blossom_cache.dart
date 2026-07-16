import 'dart:convert';
import 'dart:typed_data';

import 'package:blossom_cache/blossom_cache.dart' as blossom;

class MemoryBlossomCache implements blossom.BlossomCache {
  final Map<String, Uint8List> _bytes = {};
  final Map<String, blossom.BlobDescriptor> _descriptors = {};

  @override
  Future<blossom.BlobDescriptor> put(
    Uint8List bytes, {
    String? sha256,
    String? type,
    bool pinned = false,
  }) async {
    final key = sha256 ?? base64Url.encode(bytes);
    final now = DateTime.now().toUtc();
    final descriptor = blossom.BlobDescriptor(
      sha256: key,
      size: bytes.length,
      type: type,
      uploadedAt: now,
      lastAccessedAt: now,
      pinned: pinned,
    );
    _bytes[key] = bytes;
    _descriptors[key] = descriptor;
    return descriptor;
  }

  @override
  Future<Uint8List?> get(String sha256) async => _bytes[sha256];

  @override
  Future<blossom.BlobDescriptor?> head(String sha256) async =>
      _descriptors[sha256];

  @override
  Future<bool> delete(String sha256) async {
    final existed = _bytes.remove(sha256) != null;
    _descriptors.remove(sha256);
    return existed;
  }

  @override
  Future<bool> pin(String sha256) async => _setPinned(sha256, true);

  @override
  Future<bool> unpin(String sha256) async => _setPinned(sha256, false);

  @override
  Future<List<blossom.BlobDescriptor>> list() async =>
      _descriptors.values.toList();

  Future<bool> _setPinned(String sha256, bool pinned) async {
    final current = _descriptors[sha256];
    if (current == null || current.pinned == pinned) return false;
    _descriptors[sha256] = blossom.BlobDescriptor(
      sha256: current.sha256,
      size: current.size,
      type: current.type,
      uploadedAt: current.uploadedAt,
      lastAccessedAt: current.lastAccessedAt,
      pinned: pinned,
    );
    return true;
  }
}
