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
    String? pinBy,
  }) async {
    final key = sha256 ?? base64Url.encode(bytes);
    final now = DateTime.now().toUtc();
    final descriptor = blossom.BlobDescriptor(
      sha256: key,
      size: bytes.length,
      type: type,
      uploadedAt: now,
      lastAccessedAt: now,
      pinnedBy: {...?_descriptors[key]?.pinnedBy, ?pinBy},
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
  Future<bool> pin(
    String sha256, {
    String by = blossom.BlossomCache.defaultHolder,
  }) async {
    final current = _descriptors[sha256];
    if (current == null || current.pinnedBy.contains(by)) return false;
    _setHolders(current, {...current.pinnedBy, by});
    return true;
  }

  @override
  Future<bool> unpin(
    String sha256, {
    String by = blossom.BlossomCache.defaultHolder,
  }) async {
    final current = _descriptors[sha256];
    if (current == null || !current.pinnedBy.contains(by)) return false;
    _setHolders(current, {...current.pinnedBy}..remove(by));
    return true;
  }

  @override
  Future<int> unpinAll(String by) async {
    var released = 0;
    for (final current in _descriptors.values.toList()) {
      if (!current.pinnedBy.contains(by)) continue;
      _setHolders(current, {...current.pinnedBy}..remove(by));
      released++;
    }
    return released;
  }

  @override
  Future<List<blossom.BlobDescriptor>> list() async =>
      _descriptors.values.toList();

  @override
  Future<void> clearAllLocalData() async {
    _bytes.clear();
    _descriptors.clear();
  }

  void _setHolders(blossom.BlobDescriptor current, Set<String> holders) {
    _descriptors[current.sha256] = blossom.BlobDescriptor(
      sha256: current.sha256,
      size: current.size,
      type: current.type,
      uploadedAt: current.uploadedAt,
      lastAccessedAt: current.lastAccessedAt,
      pinnedBy: holders,
    );
  }
}
