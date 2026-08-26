import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/models/ndk_data_response.dart';
import 'package:nmail_core/services/device_connectivity_service.dart';
import 'package:nmail_core/services/metadata_reader.dart';
import 'package:nmail_core/services/relay_list_discovery.dart';

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

  late final RelayListDiscovery _discovery = RelayListDiscovery(
    _ndk,
    device: Get.find<DeviceConnectivityService>(),
  );
  late final MetadataReader _reader = MetadataReader(_ndk, _discovery);

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

  /// Drops the slot for [pubkey] and blanks it first, so widgets still holding
  /// the old reference stop showing a profile the app has just erased.
  void forget(String pubkey) {
    _cache.remove(pubkey)?.value = null;
  }

  /// The underlying local-first read, for callers that need to tell "not known
  /// yet" from "no profile exists".
  NdkDataResponse<Metadata> read(String pubkey, {Duration? timeout}) =>
      _reader.read(pubkey, timeout: timeout);

  /// Resolves through the author's write relays, and returns null rather than
  /// throwing when no relay could confirm the absence.
  Future<Metadata?> load(String pubkey, {Duration? timeout}) async {
    try {
      return await _reader.load(pubkey, timeout: timeout);
    } catch (_) {
      return null;
    }
  }

  /// Many profiles at once, each resolved through its author's write relays.
  /// Authors whose profile could not be found are absent from the map.
  Future<Map<String, Metadata>> loadMany(
    List<String> pubkeys, {
    Duration? timeout,
  }) async {
    try {
      final loaded = await _reader.loadMany(pubkeys, timeout: timeout);
      for (final entry in loaded.entries) {
        _cache[entry.key]?.value = entry.value;
      }
      return loaded;
    } catch (_) {
      return const {};
    }
  }

  @override
  void onClose() {
    _discovery.dispose();
    super.onClose();
  }

  Future<void> _load(String pubkey) async {
    try {
      await for (final value in _reader.read(pubkey).stream) {
        final metadata = value.value;
        if (metadata != null) _cache[pubkey]?.value = metadata;
      }
    } catch (_) {
      // Absence could not be concluded: keep showing whatever is known.
    }
  }
}
