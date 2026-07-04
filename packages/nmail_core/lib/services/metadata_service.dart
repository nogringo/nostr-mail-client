import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

/// Reactive, in-RAM cache of Nostr profile metadata (kind 0).
///
/// NDK resolves metadata asynchronously - even a cache hit goes through the
/// async Sembast cache - so avatars and names "flash" from a placeholder to
/// the real value on every widget build. This service keeps one [Rx] per
/// pubkey for the whole app lifetime: the first lookup returns null and kicks
/// off a one-shot load, every later lookup is synchronous, so the value never
/// flashes again once resolved.
///
/// Read [of] inside an `Obx` to rebuild when the metadata arrives.
class MetadataService extends GetxService {
  final Ndk _ndk = Get.find<Ndk>();

  /// One reactive slot per pubkey, kept for the app's lifetime.
  final Map<String, Rx<Metadata?>> _cache = {};

  /// Reactive accessor. Returns immediately with whatever is known (possibly
  /// null) and triggers a background load on the first miss. Read `.value`
  /// inside an `Obx` to rebuild once the metadata is resolved.
  Rx<Metadata?> of(String pubkey) {
    final existing = _cache[pubkey];
    if (existing != null) return existing;

    final slot = Rx<Metadata?>(null);
    _cache[pubkey] = slot;
    _load(pubkey);
    return slot;
  }

  Future<void> _load(String pubkey) async {
    final metadata = await _ndk.metadata.loadMetadata(pubkey);
    if (metadata == null) return;

    _cache[pubkey]?.value = metadata;
  }
}
