import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ndk/ndk.dart';
import 'package:system_theme/system_theme.dart';

import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import 'mail_entry_form_controller.dart';
import 'mailboxes_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/models/community_theme.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/services/theme_service.dart';
import 'package:nmail_core/utils/seed_color_from_image.dart';

class SettingsController extends GetxController {
  final _storageService = GetIt.I<StorageService>();
  final _themeService = GetIt.I<ThemeService>();
  StreamSubscription? _authSubscription;

  static const _alwaysLoadImagesKey = 'always_load_images';
  static const _dohServerKey = 'doh_server';
  static const defaultDohServer = 'https://cloudflare-dns.com/dns-query';
  static const _backgroundImageKey = 'background_image';
  static const themeModeKey = 'theme_mode';
  static const localeKey = 'locale';
  static const _debugToolsUnlockedKey = 'debug_tools_unlocked';

  final alwaysLoadImages = false.obs;
  final dohServer = defaultDohServer.obs;
  final notificationsEnabled = false.obs;

  /// Notification setting of every account on this device, keyed by pubkey.
  /// [notificationsEnabled] mirrors the active account's entry.
  final notificationsByAccount = <String, bool>{}.obs;

  /// Null until the user writes one: [signature] then shows the default.
  final emailSignature = RxnString();
  final backgroundImage = Rxn<String>();
  final themeMode = ThemeMode.system.obs;
  final locale = Rxn<Locale>();
  final dynamicTheme = true.obs;

  /// `#RRGGBB` seeding the theme while [dynamicTheme] is off, or null for the
  /// system accent color.
  final themeColor = RxnString();

  /// A color from outside the suggested palette, kept while another one is
  /// selected.
  final customThemeColor = RxnString();
  final paletteStyle = DynamicSchemeVariant.tonalSpot.obs;

  /// Address of the applied community theme, until a theme setting changes.
  final communityTheme = RxnString();
  final lightSeedColor = SystemTheme.accentColor.accent.obs;
  final darkSeedColor = SystemTheme.accentColor.accent.obs;
  final debugToolsUnlocked = false.obs;

  NostrMailService get _nostrMailService => GetIt.I<NostrMailService>();

  String? get _pubkey => _nostrMailService.getPublicKey();

  String get _backgroundKey =>
      _pubkey != null ? '${_backgroundImageKey}_$_pubkey' : _backgroundImageKey;

  String get notificationLanguageTag {
    final selectedLocale = locale.value;
    if (selectedLocale != null) return selectedLocale.toLanguageTag();

    return _resolveSupportedLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
    ).toLanguageTag();
  }

  /// Awaitable initialisation. Call this once via `Get.putAsync` before
  /// `runApp` so the first frame already has the saved theme mode and locale -
  /// otherwise MaterialApp would briefly render with the defaults before
  /// `_loadSettings` finishes.
  Future<SettingsController> init() async {
    await _loadSettings();
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    // _loadSettings ran in init() above; here we only wire the auth listener
    // so settings refresh on login/logout.
    _authSubscription = GetIt.I<Ndk>().accounts.authStateChanges.listen(
      (_) => _loadSettings(),
    );
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadSettings() async {
    final results = await Future.wait([
      _storageService.getSetting<bool>(_alwaysLoadImagesKey),
      _storageService.getSetting<String>(_backgroundKey),
      _storageService.getSetting<int>(themeModeKey),
      _storageService.getSetting<bool>(ThemeService.dynamicThemeKey),
      _storageService.getSetting<String>(ThemeService.themeColorKey),
      _storageService.getSetting<String>(ThemeService.paletteStyleKey),
      _storageService.getSetting<String>(localeKey),
      _storageService.getSetting<String>(_dohServerKey),
      _storageService.getSetting<bool>(_debugToolsUnlockedKey),
      _storageService.getSetting<String>(ThemeService.communityThemeKey),
    ]);

    alwaysLoadImages.value = (results[0] as bool?) ?? false;
    emailSignature.value = _cachedSignature;

    backgroundImage.value = results[1] as String?;
    themeMode.value = ThemeMode.values[(results[2] as int?) ?? 0];
    dynamicTheme.value = (results[3] as bool?) ?? true;

    themeColor.value = results[4] as String?;
    if (_isCustomThemeColor(themeColor.value)) {
      customThemeColor.value = themeColor.value;
    }
    paletteStyle.value =
        DynamicSchemeVariant.values.asNameMap()[results[5]] ??
        DynamicSchemeVariant.tonalSpot;
    communityTheme.value = results[9] as String?;

    final savedLocale = results[6] as String?;
    locale.value = _localeFromStorage(savedLocale);
    dohServer.value = (results[7] as String?) ?? defaultDohServer;
    debugToolsUnlocked.value = (results[8] as bool?) ?? false;

    await _loadNotificationSettings();

    await _refreshTheme();

    _refreshSignatureFromRelays();
  }

  /// Covers every account on this device, not only the active one: each carries
  /// its own subscription on the push server.
  Future<void> _loadNotificationSettings() async {
    if (!GetIt.I.isRegistered<PushSubscriptionService>()) return;

    final service = GetIt.I<PushSubscriptionService>();
    final active = _pubkey;
    final loaded = <String, bool>{};

    for (final pubkey in GetIt.I<Ndk>().accounts.accounts.keys) {
      loaded[pubkey] = pubkey == active
          ? await service.resolveEnabled(pubkey)
          : await service.isEnabled(pubkey);
    }

    notificationsByAccount.value = loaded;
    notificationsEnabled.value = active == null
        ? false
        : loaded[active] ?? false;
  }

  String signature(AppLocalizations l) =>
      emailSignature.value ??
      '--\n${l.settingsEmailSignatureDefault}\nhttps://nostrmail.org';

  /// Read the signature from the Nostr private-settings cache (primed by
  /// `NostrMailService.activateForCurrentAccount()`).
  String? get _cachedSignature {
    if (!_nostrMailService.hasAccount) return null;
    return _nostrMailService.client.cachedPrivateSettings()?.signature;
  }

  Future<void> _refreshSignatureFromRelays() async {
    final pubkey = _pubkey;
    if (pubkey == null) return;
    try {
      final remote =
          (await _nostrMailService.client.fetchPrivateSettings())?.signature;
      // An account switch during the fetch would land this on the new account.
      if (_pubkey != pubkey) return;
      if (remote != null) emailSignature.value = remote;
    } catch (_) {
      return;
    }
  }

  /// Pull the synced signature into the reactive value. Called by
  /// `AuthController.onLoggedIn` once the client is attached to the new
  /// account, since `authStateChanges` fires before that.
  Future<void> reloadSyncedSettings() async {
    emailSignature.value = _cachedSignature;
    final mailboxes = GetIt.I<MailboxesController>()..applyCached();
    await _refreshSignatureFromRelays();
    mailboxes.applyCached();
  }

  Future<void> setAlwaysLoadImages(bool value) async {
    alwaysLoadImages.value = value;
    await _storageService.saveSetting(_alwaysLoadImagesKey, value);
  }

  /// An empty [value] restores [defaultDohServer].
  Future<void> setDohServer(String value) async {
    final server = value.trim();
    if (server.isEmpty) {
      dohServer.value = defaultDohServer;
      await _storageService.deleteSetting(_dohServerKey);
      return;
    }
    dohServer.value = server;
    await _storageService.saveSetting(_dohServerKey, server);
  }

  Future<void> unlockDebugTools() async {
    debugToolsUnlocked.value = true;
    await _storageService.saveSetting(_debugToolsUnlockedKey, true);
  }

  Future<void> lockDebugTools() async {
    debugToolsUnlocked.value = false;
    await _storageService.deleteSetting(_debugToolsUnlockedKey);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final pubkey = _pubkey;
    if (pubkey == null) {
      notificationsEnabled.value = false;
      return;
    }
    await setNotificationsEnabledFor(pubkey, value);
  }

  /// Enabling requests OS notification permission first; if it is denied the
  /// toggle stays off. The permission is device-wide but the subscription is
  /// per account, so a second account only goes through the transport step.
  Future<void> setNotificationsEnabledFor(String pubkey, bool value) async {
    if (value) {
      if (!Get.find<AuthController>().isLoggedIn.value) return;

      final granted = await GetIt.I<NotificationService>().requestPermissions();
      if (!granted) return;

      if (GetIt.I.isRegistered<PushRegistrationService>()) {
        final pushService = GetIt.I<PushRegistrationService>();
        if (!await pushService.requestTransportPermission()) return;
        await pushService.prepareCurrentTransport();
      }
    }

    notificationsByAccount[pubkey] = value;
    if (pubkey == _pubkey) notificationsEnabled.value = value;

    if (GetIt.I.isRegistered<PushSubscriptionService>()) {
      await GetIt.I<PushSubscriptionService>().setEnabled(
        pubkey: pubkey,
        value: value,
      );
    }
  }

  /// Set the email signature and sync to Nostr.
  Future<void> setEmailSignature(String value) async {
    emailSignature.value = value;

    if (_nostrMailService.hasAccount) {
      try {
        await _nostrMailService.client.updatePrivateSettings(signature: value);
      } catch (_) {
        return;
      }
    }
  }

  Future<void> setBackgroundImage(String? value) async {
    await _saveBackgroundImage(value);
    await _forgetCommunityTheme();

    if (dynamicTheme.value) await _refreshTheme();
  }

  Future<void> _saveBackgroundImage(String? value) async {
    backgroundImage.value = value;
    if (value != null && value.isNotEmpty) {
      await _storageService.saveSetting(_backgroundKey, value);
    } else {
      await _storageService.deleteSetting(_backgroundKey);
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
    await _saveThemeMode(value);
    await _forgetCommunityTheme();
  }

  Future<void> _saveThemeMode(ThemeMode value) async {
    themeMode.value = value;
    await _storageService.saveSetting(themeModeKey, value.index);
  }

  /// Set the app locale, or pass null to follow the system locale.
  Future<void> setLocale(Locale? value) async {
    locale.value = value;
    if (value == null) {
      await _storageService.deleteSetting(localeKey);
    } else {
      await _storageService.saveSetting(localeKey, _localeToStorage(value));
    }

    await _refreshPushRegistrationLanguage();
  }

  Locale? _localeFromStorage(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.replaceAll('-', '_').split('_');
    if (parts.length == 1) return Locale(parts.first);

    return Locale(parts.first, parts[1].toUpperCase());
  }

  String _localeToStorage(Locale value) {
    final countryCode = value.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return value.languageCode;
    }

    return '${value.languageCode}_$countryCode';
  }

  Locale _resolveSupportedLocale(List<Locale> preferredLocales) {
    const fallback = Locale('en');
    const supportedLocales = AppLocalizations.supportedLocales;

    for (final preferred in preferredLocales) {
      for (final supported in supportedLocales) {
        if (_localeMatchesExactly(preferred, supported)) return supported;
      }
    }

    for (final preferred in preferredLocales) {
      for (final supported in supportedLocales) {
        if (preferred.languageCode == supported.languageCode) {
          return supported;
        }
      }
    }

    return fallback;
  }

  bool _localeMatchesExactly(Locale a, Locale b) {
    return a.languageCode == b.languageCode &&
        a.scriptCode == b.scriptCode &&
        a.countryCode == b.countryCode;
  }

  Future<void> _refreshPushRegistrationLanguage() async {
    if (!GetIt.I.isRegistered<PushSubscriptionService>()) return;
    await GetIt.I<PushSubscriptionService>().syncAll();
  }

  Future<void> setDynamicTheme(bool value) async {
    await _saveDynamicTheme(value);
    await _forgetCommunityTheme();
    await _refreshTheme();
  }

  Future<void> _saveDynamicTheme(bool value) async {
    dynamicTheme.value = value;
    await _storageService.saveSetting(ThemeService.dynamicThemeKey, value);
  }

  /// [hex] is `#RRGGBB`, or null for the system accent color.
  Future<void> setThemeColor(String? hex) async {
    await _saveThemeColor(hex);
    await _forgetCommunityTheme();
    await _refreshTheme();
  }

  Future<void> _saveThemeColor(String? hex) async {
    themeColor.value = hex;
    if (hex == null) {
      await _storageService.deleteSetting(ThemeService.themeColorKey);
    } else {
      await _storageService.saveSetting(ThemeService.themeColorKey, hex);
    }
  }

  Future<void> pickCustomThemeColor(String hex) async {
    if (_isCustomThemeColor(hex)) customThemeColor.value = hex;
    await setThemeColor(hex);
  }

  /// Where the custom color dialog opens.
  Color get customThemeColorSeed =>
      MailboxesController.parseEntryColor(customThemeColor.value) ??
      MailboxesController.parseEntryColor(themeColor.value) ??
      lightSeedColor.value;

  bool _isCustomThemeColor(String? hex) =>
      hex != null &&
      !MailEntryFormController.palette.containsKey(hex.toUpperCase());

  Future<void> setPaletteStyle(DynamicSchemeVariant value) async {
    paletteStyle.value = value;
    _applyTheme();
    await _storageService.saveSetting(ThemeService.paletteStyleKey, value.name);
    await _forgetCommunityTheme();
  }

  /// [background] is a background value, see [BackgroundPreset].
  Future<void> applyCommunityTheme(
    CommunityTheme theme, {
    required String background,
  }) async {
    final seedHex = MailboxesController.formatEntryColor(theme.seedColor);
    if (_isCustomThemeColor(seedHex)) customThemeColor.value = seedHex;

    paletteStyle.value = theme.variant;
    await _storageService.saveSetting(
      ThemeService.paletteStyleKey,
      theme.variant.name,
    );

    await _saveDynamicTheme(false);
    await _saveThemeColor(seedHex);
    await _saveThemeMode(
      theme.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    );
    await _saveBackgroundImage(background);

    await markCommunityTheme(theme.address);

    await _refreshTheme();
  }

  /// Marks [address] as the current look without changing any setting.
  Future<void> markCommunityTheme(String address) async {
    communityTheme.value = address;
    await _storageService.saveSetting(ThemeService.communityThemeKey, address);
  }

  Future<void> _forgetCommunityTheme() async {
    if (communityTheme.value == null) return;
    communityTheme.value = null;
    await _storageService.deleteSetting(ThemeService.communityThemeKey);
  }

  Future<void> _refreshTheme() async {
    final (light, dark) = await _themeSeedColors();
    lightSeedColor.value = light;
    darkSeedColor.value = dark;
    _applyTheme();
  }

  Future<(Color, Color)> _themeSeedColors() async {
    final accent = SystemTheme.accentColor.accent;
    if (!dynamicTheme.value) {
      final seed =
          MailboxesController.parseEntryColor(themeColor.value) ?? accent;
      return (seed, seed);
    }

    final background = backgroundImage.value;
    if (BackgroundPreset.isSystemColorValue(background)) {
      return (accent, accent);
    }

    final preset = background == null || background.isEmpty
        ? BackgroundPreset.defaultPreset()
        : BackgroundPreset.fromStorageValue(background);
    if (preset != null) return (preset.lightSeedColor, preset.darkSeedColor);
    if (!BackgroundPreset.isCustomImageValue(background)) {
      return (accent, accent);
    }

    final seed = await _backgroundImageSeedColor(background!) ?? accent;
    return (seed, seed);
  }

  /// Cached per image, so startup does not decode the background again.
  Future<Color?> _backgroundImageSeedColor(String image) async {
    final key = '${ThemeService.backgroundSeedColorKeyPrefix}$image';
    final cached = MailboxesController.parseEntryColor(
      await _storageService.getSetting<String>(key),
    );
    if (cached != null) return cached;

    try {
      final seed = await seedColorFromImage(
        BackgroundPreset.customImage(image),
      );
      await _storageService.saveSetting(
        key,
        MailboxesController.formatEntryColor(seed),
      );
      return seed;
    } catch (_) {
      return null;
    }
  }

  void _applyTheme() {
    _themeService.setColorSchemes(
      ColorScheme.fromSeed(
        seedColor: lightSeedColor.value,
        dynamicSchemeVariant: paletteStyle.value,
      ),
      ColorScheme.fromSeed(
        seedColor: darkSeedColor.value,
        brightness: Brightness.dark,
        dynamicSchemeVariant: paletteStyle.value,
      ),
    );
  }

  Future<void> resetApplication() async {
    await Get.find<AuthController>().logoutAll();

    // Reset in-memory state
    alwaysLoadImages.value = false;
    dohServer.value = defaultDohServer;
    notificationsEnabled.value = false;
    notificationsByAccount.clear();
    emailSignature.value = null;
    backgroundImage.value = null;
    themeMode.value = ThemeMode.system;
    locale.value = null;
    dynamicTheme.value = true;
    themeColor.value = null;
    customThemeColor.value = null;
    paletteStyle.value = DynamicSchemeVariant.tonalSpot;
    communityTheme.value = null;
    lightSeedColor.value = SystemTheme.accentColor.accent;
    darkSeedColor.value = SystemTheme.accentColor.accent;
    debugToolsUnlocked.value = false;
    _themeService.clear();

    // Navigate to login
    AppRouter.router.go(AppRoutes.login);
  }
}
