import 'dart:convert';

import 'package:broadcast_queue_shim_for_ndk/broadcast_queue_shim_for_ndk.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide FirstWhereExt;
import 'package:ndk/ndk.dart' hide RelaySet;

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/backgrounds_controller.dart';
import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class CommunityThemeController extends GetxController {
  CommunityThemeController({
    required this.pubkey,
    required this.identifier,
    this.relays = const [],
  });

  final String pubkey;
  final String identifier;

  /// Hints of the link that opened the theme.
  final List<String> relays;

  final theme = Rxn<CommunityTheme>();
  final isLoading = false.obs;
  final isApplying = false.obs;
  final isMuting = false.obs;

  /// The text copied in the last two seconds.
  final copied = RxnString();

  final _revealed = false.obs;

  String get address => '${CommunityTheme.kind}:$pubkey:$identifier';

  /// Registered when the theme opens from the themes page.
  CommunityThemesController? get _browser =>
      Get.isRegistered<CommunityThemesController>()
      ? Get.find<CommunityThemesController>()
      : null;

  bool get isHidden {
    final theme = this.theme.value;
    if (theme == null || _revealed.value) return false;
    return _browser?.isHidden(theme) ??
        CommunityThemesController.startsHidden(theme);
  }

  @override
  void onInit() {
    super.onInit();
    theme.value = _browser?.themes.firstWhereOrNull(
      (theme) => theme.address == address,
    );
    if (theme.value == null) load();
  }

  void reveal() {
    _revealed.value = true;
    if (theme.value case final theme?) _browser?.reveal(theme);
  }

  Future<void> load() async {
    isLoading.value = true;
    final ndk = Get.find<Ndk>();
    try {
      final cached = await ndk.config.cache
          .loadEvents(pubKeys: [pubkey], kinds: [CommunityTheme.kind])
          .catchError((_) => <Nip01Event>[]);
      if (isClosed) return;
      _show(cached);

      final fetched = await ndk.requests
          .query(
            name: 'community-theme',
            filter: Filter(
              kinds: [CommunityTheme.kind],
              authors: [pubkey],
              dTags: [identifier],
            ),
            explicitRelays: {...NostrConfig.communityThemeRelays, ...relays},
            timeout: const Duration(seconds: 10),
            cacheRead: false,
          )
          .future;
      if (isClosed) return;
      _show([...cached, ...fetched]);
    } catch (_) {
      // A cached version stays on screen.
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> apply(BuildContext context) async {
    final theme = this.theme.value;
    if (theme == null || isApplying.value) return;
    final l = AppLocalizations.of(context);
    isApplying.value = true;

    try {
      final imageUrl = theme.backgroundImageUrl;
      final background = imageUrl != null
          ? await Get.find<BackgroundsController>().downloadToGallery(imageUrl)
          : BackgroundPreset.systemColorStorageValue;
      await Get.find<SettingsController>().applyCommunityTheme(
        theme,
        background: background,
      );
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.communityThemesImageError);
      }
    } finally {
      if (!isClosed) isApplying.value = false;
    }
  }

  /// Adds the author to the private part of the NIP-51 mute list.
  ///
  /// Throws when no relay answers or the signer fails, so a list it could not
  /// read is never replaced by an old copy or an empty one.
  Future<void> muteAuthor() async {
    isMuting.value = true;
    try {
      final ndk = Get.find<Ndk>();
      final account = ndk.accounts.getLoggedAccount()!;
      final response = ndk.requests.query(
        name: 'mute-list',
        filter: Filter(
          kinds: [Nip51List.kMute],
          authors: [account.pubkey],
          limit: 1,
        ),
        explicitRelays: await Get.find<NostrMailService>().getOutboxRelays(),
        timeout: const Duration(seconds: 5),
        cacheRead: false,
      );
      final fetched = await response.future;
      final outcomes = await response.relayOutcomesDone;
      if (!outcomes.values.any(
        (outcome) => outcome.status == RelayRequestStatus.eose,
      )) {
        throw StateError('No relay answered the mute list query');
      }
      final cached = await ndk.config.cache.loadEvents(
        pubKeys: [account.pubkey],
        kinds: [Nip51List.kMute],
      );
      final current = ([
        ...fetched,
        ...cached,
      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt))).firstOrNull;

      final content = current?.content ?? '';
      final decrypted = content.isEmpty
          ? '[]'
          : content.contains('?iv=')
          // Lists written before NIP-44.
          // ignore: deprecated_member_use
          ? await account.signer.decrypt(content, account.pubkey)
          : await account.signer.decryptNip44(
              ciphertext: content,
              senderPubKey: account.pubkey,
            );
      final privateTags = jsonDecode(decrypted!) as List<dynamic>;
      final publicTags = current?.tags ?? [];
      final alreadyMuted = [...publicTags, ...privateTags].any(
        (tag) =>
            tag is List &&
            tag.length > 1 &&
            tag[0] == Nip51List.kPubkey &&
            tag[1] == pubkey,
      );

      if (!alreadyMuted) {
        final unsigned = Nip01Event(
          pubKey: account.pubkey,
          kind: Nip51List.kMute,
          tags: publicTags,
          content: (await account.signer.encryptNip44(
            plaintext: jsonEncode([
              ...privateTags,
              [Nip51List.kPubkey, pubkey],
            ]),
            recipientPubKey: account.pubkey,
          ))!,
        );
        final signed = await account.signer.sign(unsigned);
        await ndk.config.cache.saveEvent(signed);
        await Get.find<OfflineBroadcast>().broadcast(
          signed,
          relaySet: RelaySet.outbox(account.pubkey),
          pubkey: account.pubkey,
        );
      }

      _browser?.hideAuthor(pubkey);
    } finally {
      if (!isClosed) isMuting.value = false;
    }
  }

  void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    copied.value = text;
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed && copied.value == text) copied.value = null;
    });
  }

  void _show(List<Nip01Event> events) {
    final latest = CommunityTheme.latest(
      events,
    ).firstWhereOrNull((theme) => theme.address == address);
    if (latest != null) theme.value = latest;
  }
}
