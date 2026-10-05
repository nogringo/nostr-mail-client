import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';

import 'package:nmail_core/config/nostr_config.dart';
import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/models/theme_color_family.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';

class CommunityThemesController extends ChangeNotifier {
  CommunityThemesController() {
    searchController.addListener(_onSearchChanged);
    load();
  }

  List<CommunityTheme> themes = [];
  bool isLoading = false;

  /// Null shows every theme.
  Brightness? get brightness => _brightness;
  set brightness(Brightness? value) {
    _brightness = value;
    notifyListeners();
  }

  /// Null shows every color.
  ThemeColorFamily? get colorFamily => _colorFamily;
  set colorFamily(ThemeColorFamily? value) {
    _colorFamily = value;
    notifyListeners();
  }

  /// Null shows themes with and without a background image.
  bool? get hasImage => _hasImage;
  set hasImage(bool? value) {
    _hasImage = value;
    notifyListeners();
  }

  Brightness? _brightness;
  ThemeColorFamily? _colorFamily;
  bool? _hasImage;

  final searchController = TextEditingController();
  String query = '';

  /// Authors the user muted (NIP-51 kind 10000), in this client or another.
  var _muted = <String>{};

  /// Addresses of the themes shown past their content warning.
  final _revealed = <String>{};

  bool _isDisposed = false;

  bool isHidden(CommunityTheme theme) =>
      !_revealed.contains(theme.address) && startsHidden(theme);

  /// Behind its content warning, unless it is the user's own or applied.
  static bool startsHidden(CommunityTheme theme) =>
      theme.contentWarning != null &&
      theme.pubkey != GetIt.I<Ndk>().accounts.getPublicKey() &&
      theme.address != Get.find<SettingsController>().communityTheme.value;

  void reveal(CommunityTheme theme) {
    _revealed.add(theme.address);
    notifyListeners();
  }

  /// [filterByImage] is false where backgrounds are never shown.
  List<CommunityTheme> visibleThemes({required bool filterByImage}) {
    final hasImage = filterByImage ? _hasImage : null;
    return themes
        .where(
          (theme) =>
              (_brightness == null || theme.brightness == _brightness) &&
              (_colorFamily == null || theme.colorFamily == _colorFamily) &&
              (hasImage == null ||
                  (theme.backgroundImageUrl != null) == hasImage) &&
              theme.matches(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _isDisposed = true;
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (query == this.query) return;
    this.query = query;
    notifyListeners();
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final ndk = GetIt.I<Ndk>();
    try {
      await _readMuted(ndk);
      final cached = await ndk.config.cache
          .loadEvents(kinds: [CommunityTheme.kind])
          .catchError((_) => <Nip01Event>[]);
      if (_isDisposed) return;
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
      if (_isDisposed) return;
      _show([...cached, ...fetched]);
    } catch (_) {
      // The cached themes stay on screen.
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Puts the user's new theme first, with no filter or search hiding it.
  void showPublished(CommunityTheme theme) {
    _brightness = null;
    _colorFamily = null;
    _hasImage = null;
    searchController.clear();
    themes.insert(0, theme);
    notifyListeners();
  }

  /// A copy by someone else that this author's theme hid shows on next load.
  void hideAuthor(String pubkey) {
    _muted = {..._muted, pubkey};
    themes.removeWhere((theme) => theme.pubkey == pubkey);
    notifyListeners();
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
    themes = CommunityTheme.withoutCopies(
      CommunityTheme.latest(unmuted.toList()),
    );
    notifyListeners();
  }
}
