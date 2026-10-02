import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/models/theme_color_family.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class CommunityThemesController extends GetxController {
  final themes = <CommunityTheme>[].obs;
  final isLoading = false.obs;

  /// Null shows every theme.
  final brightness = Rxn<Brightness>();

  /// Null shows every color.
  final colorFamily = Rxn<ThemeColorFamily>();

  /// Null shows themes with and without a background image.
  final hasImage = RxnBool();

  final searchController = TextEditingController();
  final query = ''.obs;

  /// Authors the user muted (NIP-51 kind 10000), in this client or another.
  var _muted = <String>{};

  /// Addresses of the themes shown past their content warning.
  final _revealed = <String>{}.obs;

  bool isHidden(CommunityTheme theme) =>
      !_revealed.contains(theme.address) && startsHidden(theme);

  /// Behind its content warning, unless it is the user's own or applied.
  static bool startsHidden(CommunityTheme theme) =>
      theme.contentWarning != null &&
      theme.pubkey != Get.find<Ndk>().accounts.getPublicKey() &&
      theme.address != Get.find<SettingsController>().communityTheme.value;

  void reveal(CommunityTheme theme) => _revealed.add(theme.address);

  /// [filterByImage] is false where backgrounds are never shown.
  List<CommunityTheme> visibleThemes({required bool filterByImage}) {
    final brightness = this.brightness.value;
    final colorFamily = this.colorFamily.value;
    final hasImage = filterByImage ? this.hasImage.value : null;
    final query = this.query.value;
    return themes
        .where(
          (theme) =>
              (brightness == null || theme.brightness == brightness) &&
              (colorFamily == null || theme.colorFamily == colorFamily) &&
              (hasImage == null ||
                  (theme.backgroundImageUrl != null) == hasImage) &&
              theme.matches(query),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(
      () => query.value = searchController.text.trim(),
    );
    load();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    final ndk = Get.find<Ndk>();
    try {
      await _readMuted(ndk);
      final cached = await ndk.config.cache
          .loadEvents(kinds: [CommunityTheme.kind])
          .catchError((_) => <Nip01Event>[]);
      if (isClosed) return;
      if (cached.isNotEmpty) _show(cached);

      final mutedRefresh = _refreshMuted(ndk);
      final fetched = await ndk.requests
          .query(
            name: 'community-themes',
            filter: Filter(kinds: [CommunityTheme.kind], limit: 500),
            explicitRelays: NostrConfig.communityThemeRelays,
            timeout: const Duration(seconds: 10),
            paginate: true,
            // Cached events would set where each relay's next page starts.
            cacheRead: false,
          )
          .future;
      await mutedRefresh;
      if (isClosed) return;
      _show([...cached, ...fetched]);
    } catch (_) {
      // The cached themes stay on screen.
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  /// Puts the user's new theme first, with no filter or search hiding it.
  void showPublished(CommunityTheme theme) {
    brightness.value = null;
    colorFamily.value = null;
    hasImage.value = null;
    searchController.clear();
    themes.insert(0, theme);
  }

  /// Reads the cache only, so cached themes do not wait on relays.
  Future<void> _readMuted(Ndk ndk) async {
    final pubkey = ndk.accounts.getPublicKey();
    if (pubkey == null) return;
    try {
      final cached = await ndk.config.cache.loadEvents(
        pubKeys: [pubkey],
        kinds: [Nip51List.kMute],
      );
      if (cached.isEmpty) return;
      // Reads the same cache, and remembers the decrypted private part.
      final list = await ndk.lists.getSingleNip51List(Nip51List.kMute);
      _muted = {...?list?.pubKeys.map((element) => element.value)};
    } catch (_) {
      // Themes still load without the list.
    }
  }

  Future<void> _refreshMuted(Ndk ndk) async {
    final pubkey = ndk.accounts.getPublicKey();
    if (pubkey == null) return;
    try {
      // The query writes the list to the cache [_readMuted] reads.
      await ndk.requests
          .query(
            name: 'mute-list',
            filter: Filter(
              kinds: [Nip51List.kMute],
              authors: [pubkey],
              limit: 1,
            ),
            explicitRelays: await Get.find<NostrMailService>()
                .getOutboxRelays(),
            timeout: const Duration(seconds: 5),
            cacheRead: false,
          )
          .future;
    } catch (_) {
      // The cached list stays in use.
    }
    await _readMuted(ndk);
  }

  void _show(List<Nip01Event> events) {
    // Before dropping copies, so a copy by someone else is kept.
    final unmuted = events.where((event) => !_muted.contains(event.pubKey));
    themes.value = CommunityTheme.withoutCopies(
      CommunityTheme.latest(unmuted.toList()),
    );
  }
}
