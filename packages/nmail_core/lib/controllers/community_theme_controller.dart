import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/backgrounds_controller.dart';
import 'package:nmail_core/controllers/community_themes_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/models/community_theme.dart';
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
