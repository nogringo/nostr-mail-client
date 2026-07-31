import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

import '../app/routes/app_router.dart';
import '../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/services/nostr_mail_service.dart';
import 'package:nmail_core/services/notification_service.dart';
import 'package:nmail_core/services/push_registration_service.dart';
import 'package:nmail_core/services/push_subscription_service.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/services/theme_service.dart';
import 'package:nmail_core/utils/color_scheme_serializer.dart';
import 'package:nmail_core/utils/platform_helper.dart';

class SettingsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _themeService = Get.find<ThemeService>();
  StreamSubscription? _authSubscription;

  static const _showRawEmailKey = 'show_raw_email';
  static const _alwaysLoadImagesKey = 'always_load_images';
  static const _backgroundImageKey = 'background_image';
  static const themeModeKey = 'theme_mode';
  static const localeKey = 'locale';
  static const backgroundsDirName = 'backgrounds';
  static const _defaultSignature = '--\nSent with Nmail\nhttps://nostrmail.org';

  final showRawEmail = false.obs;
  final alwaysLoadImages = false.obs;
  final notificationsEnabled = false.obs;

  /// Notification setting of every account on this device, keyed by pubkey.
  /// [notificationsEnabled] mirrors the active account's entry.
  final notificationsByAccount = <String, bool>{}.obs;
  final emailSignature = _defaultSignature.obs;
  final backgroundImage = Rxn<String>();
  final themeMode = ThemeMode.system.obs;
  final locale = Rxn<Locale>();
  final dynamicTheme = true.obs;
  final lightColorScheme = Rxn<ColorScheme>();
  final darkColorScheme = Rxn<ColorScheme>();

  NostrMailService get _nostrMailService => Get.find<NostrMailService>();

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
    _authSubscription = Get.find<Ndk>().accounts.authStateChanges.listen(
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
      _storageService.getSetting<bool>(_showRawEmailKey),
      _storageService.getSetting<bool>(_alwaysLoadImagesKey),
      _storageService.getSetting<String>(_backgroundKey),
      _storageService.getSetting<int>(themeModeKey),
      _storageService.getSetting<bool>(ThemeService.dynamicThemeKey),
      _storageService.getSetting<String>(ThemeService.colorSchemeKeyLight),
      _storageService.getSetting<String>(ThemeService.colorSchemeKeyDark),
      _storageService.getSetting<String>(localeKey),
    ]);

    showRawEmail.value = (results[0] as bool?) ?? false;
    alwaysLoadImages.value = (results[1] as bool?) ?? false;
    emailSignature.value = _cachedSignature;

    backgroundImage.value = results[2] as String?;
    themeMode.value = ThemeMode.values[(results[3] as int?) ?? 0];
    dynamicTheme.value = (results[4] as bool?) ?? true;

    final savedLightScheme = results[5] as String?;
    if (savedLightScheme != null) {
      lightColorScheme.value = colorSchemeFromJson(savedLightScheme);
    }

    final savedDarkScheme = results[6] as String?;
    if (savedDarkScheme != null) {
      darkColorScheme.value = colorSchemeFromJson(savedDarkScheme);
    }

    final savedLocale = results[7] as String?;
    locale.value = _localeFromStorage(savedLocale);

    await _loadNotificationSettings();

    _refreshSignatureFromRelays();
  }

  /// Covers every account on this device, not only the active one: each carries
  /// its own subscription on the push server.
  Future<void> _loadNotificationSettings() async {
    if (!Get.isRegistered<PushSubscriptionService>()) return;

    final service = Get.find<PushSubscriptionService>();
    final active = _pubkey;
    final loaded = <String, bool>{};

    for (final pubkey in Get.find<Ndk>().accounts.accounts.keys) {
      loaded[pubkey] = pubkey == active
          ? await service.resolveEnabled(pubkey)
          : await service.isEnabled(pubkey);
    }

    notificationsByAccount.value = loaded;
    notificationsEnabled.value = active == null
        ? false
        : loaded[active] ?? false;
  }

  /// Read the signature from the Nostr private-settings cache (primed by
  /// `NostrMailService.activateForCurrentAccount()`), falling back to the
  /// default.
  String get _cachedSignature {
    if (!_nostrMailService.hasAccount) return _defaultSignature;
    final sig = _nostrMailService.client.cachedPrivateSettings?.signature;
    return (sig != null && sig.isNotEmpty) ? sig : _defaultSignature;
  }

  Future<void> _refreshSignatureFromRelays() async {
    final pubkey = _pubkey;
    if (pubkey == null) return;
    try {
      final remote =
          (await _nostrMailService.client.fetchPrivateSettings())?.signature;
      // An account switch during the fetch would land this on the new account.
      if (_pubkey != pubkey) return;
      if (remote != null && remote.isNotEmpty) {
        emailSignature.value = remote;
      }
    } catch (_) {
      return;
    }
  }

  /// Pull the synced signature into the reactive value. Called by
  /// `AuthController.onLoggedIn` once the client is attached to the new
  /// account, since `authStateChanges` fires before that.
  Future<void> reloadSyncedSettings() async {
    emailSignature.value = _cachedSignature;
    await _refreshSignatureFromRelays();
  }

  Future<void> setShowRawEmail(bool value) async {
    showRawEmail.value = value;
    await _storageService.saveSetting(_showRawEmailKey, value);
  }

  Future<void> setAlwaysLoadImages(bool value) async {
    alwaysLoadImages.value = value;
    await _storageService.saveSetting(_alwaysLoadImagesKey, value);
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

      final granted = await Get.find<NotificationService>()
          .requestPermissions();
      if (!granted) return;

      if (Get.isRegistered<PushRegistrationService>()) {
        final pushService = Get.find<PushRegistrationService>();
        if (!await pushService.requestTransportPermission()) return;
        await pushService.prepareCurrentTransport();
      }
    }

    notificationsByAccount[pubkey] = value;
    if (pubkey == _pubkey) notificationsEnabled.value = value;

    if (Get.isRegistered<PushSubscriptionService>()) {
      await Get.find<PushSubscriptionService>().setEnabled(
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
    backgroundImage.value = value;
    if (value != null && value.isNotEmpty) {
      await _storageService.saveSetting(_backgroundKey, value);
    } else {
      await _storageService.deleteSetting(_backgroundKey);
    }

    if (dynamicTheme.value) {
      await extractThemeFromImage(value);
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
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
    if (!Get.isRegistered<PushSubscriptionService>()) return;
    await Get.find<PushSubscriptionService>().syncAll();
  }

  Future<void> setDynamicTheme(bool value) async {
    dynamicTheme.value = value;
    await _storageService.saveSetting(ThemeService.dynamicThemeKey, value);

    if (value && backgroundImage.value != null) {
      await extractThemeFromImage(backgroundImage.value);
    } else {
      await _clearColorSchemes();
      _applyTheme();
    }
  }

  Future<void> extractThemeFromImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      await _clearColorSchemes();
      _applyTheme();
      return;
    }

    try {
      final ImageProvider provider;
      if (PlatformHelper.isNative) {
        provider = FileImage(File(imagePath));
      } else {
        provider = NetworkImage(imagePath);
      }

      // Extract both light and dark schemes in parallel
      final [light, dark] = await Future.wait([
        ColorScheme.fromImageProvider(
          provider: provider,
          brightness: Brightness.light,
        ),
        ColorScheme.fromImageProvider(
          provider: provider,
          brightness: Brightness.dark,
        ),
      ]);

      lightColorScheme.value = light;
      darkColorScheme.value = dark;

      await Future.wait([
        _storageService.saveSetting(
          ThemeService.colorSchemeKeyLight,
          colorSchemeToJson(light),
        ),
        _storageService.saveSetting(
          ThemeService.colorSchemeKeyDark,
          colorSchemeToJson(dark),
        ),
      ]);

      _applyTheme();
    } catch (e) {
      // On error, keep system color
      await _clearColorSchemes();
      _applyTheme();
    }
  }

  Future<void> _clearColorSchemes() async {
    lightColorScheme.value = null;
    darkColorScheme.value = null;
    await Future.wait([
      _storageService.deleteSetting(ThemeService.colorSchemeKeyLight),
      _storageService.deleteSetting(ThemeService.colorSchemeKeyDark),
    ]);
  }

  void _applyTheme() {
    if (dynamicTheme.value && lightColorScheme.value != null) {
      _themeService.setColorSchemes(
        lightColorScheme.value,
        darkColorScheme.value,
      );
    } else {
      _themeService.clear();
    }
  }

  Future<void> resetApplication() async {
    await Get.find<AuthController>().logoutAll();

    // Reset in-memory state
    showRawEmail.value = false;
    alwaysLoadImages.value = false;
    notificationsEnabled.value = false;
    notificationsByAccount.clear();
    emailSignature.value = _defaultSignature;
    backgroundImage.value = null;
    themeMode.value = ThemeMode.system;
    locale.value = null;
    dynamicTheme.value = true;
    lightColorScheme.value = null;
    darkColorScheme.value = null;
    _themeService.clear();

    // Navigate to login
    AppRouter.router.go(AppRoutes.login);
  }
}
