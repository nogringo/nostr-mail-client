import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/backgrounds_controller.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/models/theme_color_family.dart';
import 'package:nmail_core/utils/toast_helper.dart';

class CommunityThemesController extends GetxController {
  final themes = <CommunityTheme>[].obs;
  final isLoading = false.obs;

  /// Null shows every theme.
  final brightness = Rxn<Brightness>();

  /// Null shows every color.
  final colorFamily = Rxn<ThemeColorFamily>();

  /// Address of the theme being applied.
  final applying = RxnString();

  SettingsController get _settings => Get.find<SettingsController>();

  List<CommunityTheme> get visibleThemes {
    final brightness = this.brightness.value;
    final colorFamily = this.colorFamily.value;
    return themes
        .where(
          (theme) =>
              (brightness == null || theme.brightness == brightness) &&
              (colorFamily == null || theme.colorFamily == colorFamily),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final ndk = Get.find<Ndk>();
    try {
      final cached = await ndk.config.cache
          .loadEvents(kinds: [CommunityTheme.kind])
          .catchError((_) => <Nip01Event>[]);
      if (isClosed) return;
      if (cached.isNotEmpty) _show(cached);

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
      if (isClosed) return;
      _show([...cached, ...fetched]);
    } catch (_) {
      // The cached themes stay on screen.
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void _show(List<Nip01Event> events) {
    themes.value = CommunityTheme.withoutCopies(CommunityTheme.latest(events));
  }

  Future<void> apply(BuildContext context, CommunityTheme theme) async {
    if (applying.value != null) return;
    final l = AppLocalizations.of(context);
    applying.value = theme.address;

    try {
      final imageUrl = theme.backgroundImageUrl;
      final background = imageUrl != null
          ? await Get.find<BackgroundsController>().downloadToGallery(imageUrl)
          : BackgroundPreset.systemColorStorageValue;
      await _settings.applyCommunityTheme(theme, background: background);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.communityThemesImageError);
      }
    } finally {
      if (!isClosed) applying.value = null;
    }
  }
}
