import 'dart:io';

import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:ndk/ndk.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/relay_utils.dart';

class AccountDeletionService extends GetxService {
  static const vanishKind = 62;
  static const allRelaysTagValue = 'ALL_RELAYS';
  static const defaultVanishContent = 'Account deletion requested from Nmail';

  Ndk get _ndk => Get.find<Ndk>();
  StorageService get _storageService => Get.find<StorageService>();

  static Nip01Event buildGlobalVanishEvent({
    required String pubkey,
    String content = defaultVanishContent,
    int? createdAt,
  }) {
    return Nip01Event(
      pubKey: pubkey,
      kind: vanishKind,
      tags: const [
        ['relay', allRelaysTagValue],
      ],
      content: content,
      createdAt: createdAt ?? Nip01Event.secondsSinceEpoch(),
    );
  }

  static List<String> mergeTargetRelays(Iterable<Iterable<String>> relayLists) {
    final relays = <String>[];
    final seen = <String>{};

    for (final relayList in relayLists) {
      for (final relay in relayList) {
        final normalized = normalizeRelayUrl(relay.trim());
        if (!isValidRelayUrl(normalized) || !seen.add(normalized)) continue;
        relays.add(normalized);
      }
    }

    return relays;
  }

  Future<List<String>> targetRelaysForGlobalVanish() async {
    final nip65Relays = await _loadRelays(
      () => Get.isRegistered<NostrMailService>()
          ? Get.find<NostrMailService>().getNip65Relays()
          : Future.value(const <String, ReadWriteMarker>{}),
    );
    final dmRelays = await _loadRelays(
      () => Get.isRegistered<NostrMailService>()
          ? Get.find<NostrMailService>().getDmRelays()
          : Future.value(const <String>[]),
    );

    return mergeTargetRelays([
      NostrConfig.bootstrapRelays,
      NostrConfig.popularRelays,
      NostrConfig.recommendedInboxOutboxRelays,
      NostrConfig.recommendedDmRelays,
      nip65Relays,
      dmRelays,
    ]);
  }

  Future<List<RelayBroadcastResponse>> requestGlobalVanish({
    String content = defaultVanishContent,
  }) async {
    final account = _ndk.accounts.getLoggedAccount();
    if (account == null || !account.signer.canSign()) return const [];

    final unsigned = buildGlobalVanishEvent(
      pubkey: account.pubkey,
      content: content,
    );
    final signed = await account.signer.sign(unsigned);
    final relays = await targetRelaysForGlobalVanish();
    if (relays.isEmpty) return const [];

    final response = _ndk.broadcast.broadcast(
      nostrEvent: signed,
      specificRelays: relays,
      saveToCache: false,
    );
    return response.broadcastDoneFuture;
  }

  Future<void> clearLocalAccountData() async {
    await _storageService.clearAll();

    if (Get.isRegistered<Ndk>()) {
      await _ndk.config.cache.clearAll();
    }

    if (Get.isRegistered<NostrMailService>()) {
      final nostrMailService = Get.find<NostrMailService>();
      if (nostrMailService.isClientInitialized) {
        await nostrMailService.client.clearAll();
      }
    }

    // TODO: Use package-owned clear methods for address book, broadcast queue,
    // Blossom upload queue, and scheduled events when those APIs are available.
    await _deleteBackgroundsDirectory();
  }

  Future<void> _deleteBackgroundsDirectory() async {
    if (!PlatformHelper.isNative) return;
    try {
      final appDir = await getApplicationSupportDirectory();
      final backgroundsDir = Directory(
        p.join(appDir.path, SettingsController.backgroundsDirName),
      );
      if (await backgroundsDir.exists()) {
        await backgroundsDir.delete(recursive: true);
      }
    } catch (_) {}
  }

  Future<Iterable<String>> _loadRelays<T>(Future<T> Function() load) async {
    try {
      final result = await load();
      if (result is Map<String, ReadWriteMarker>) return result.keys;
      if (result is Iterable<String>) return result;
    } catch (_) {}
    return const [];
  }
}
