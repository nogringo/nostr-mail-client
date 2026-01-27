import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';

import '../services/nostr_mail_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import '../utils/color_scheme_serializer.dart';
import '../utils/event_verifiers.dart';
import '../utils/platform_helper.dart';

class SettingsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  final _themeService = Get.find<ThemeService>();
  StreamSubscription? _authSubscription;

  static const _showRawEmailKey = 'show_raw_email';
  static const _alwaysLoadImagesKey = 'always_load_images';
  static const _emailSignatureKey = 'email_signature';
  static const _backgroundImageKey = 'background_image';
  static const themeModeKey = 'theme_mode';
  static const skipEventVerificationKey = 'skip_event_verification';
  static const _defaultSignature =
      '--\nSent with Nmail\nhttps://github.com/nogringo/nostr-mail-client';

  final showRawEmail = false.obs;
  final alwaysLoadImages = false.obs;
  final skipEventVerification = false.obs;
  final emailSignature = _defaultSignature.obs;
  final backgroundImage = Rxn<String>();
  final themeMode = ThemeMode.system.obs;
  final dynamicTheme = false.obs;
  final lightColorScheme = Rxn<ColorScheme>();
  final darkColorScheme = Rxn<ColorScheme>();

  String? get _pubkey => Get.find<NostrMailService>().getPublicKey();

  String get _signatureKey =>
      _pubkey != null ? '${_emailSignatureKey}_$_pubkey' : _emailSignatureKey;

  String get _backgroundKey =>
      _pubkey != null ? '${_backgroundImageKey}_$_pubkey' : _backgroundImageKey;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _authSubscription = Get.find<Ndk>().accounts.stateChanges.listen(
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
      _storageService.getSetting<bool>(skipEventVerificationKey),
      _storageService.getSetting<String>(_signatureKey),
      _storageService.getSetting<String>(_backgroundKey),
      _storageService.getSetting<int>(themeModeKey),
      _storageService.getSetting<bool>(ThemeService.dynamicThemeKey),
      _storageService.getSetting<String>(ThemeService.colorSchemeKeyLight),
      _storageService.getSetting<String>(ThemeService.colorSchemeKeyDark),
    ]);

    showRawEmail.value = (results[0] as bool?) ?? false;
    alwaysLoadImages.value = (results[1] as bool?) ?? false;
    skipEventVerification.value = (results[2] as bool?) ?? false;
    emailSignature.value = (results[3] as String?) ?? _defaultSignature;
    backgroundImage.value = results[4] as String?;
    themeMode.value = ThemeMode.values[(results[5] as int?) ?? 0];
    dynamicTheme.value = (results[6] as bool?) ?? false;

    final savedLightScheme = results[7] as String?;
    if (savedLightScheme != null) {
      lightColorScheme.value = colorSchemeFromJson(savedLightScheme);
    }

    final savedDarkScheme = results[8] as String?;
    if (savedDarkScheme != null) {
      darkColorScheme.value = colorSchemeFromJson(savedDarkScheme);
    }
  }

  Future<void> setShowRawEmail(bool value) async {
    showRawEmail.value = value;
    await _storageService.saveSetting(_showRawEmailKey, value);
  }

  Future<void> setAlwaysLoadImages(bool value) async {
    alwaysLoadImages.value = value;
    await _storageService.saveSetting(_alwaysLoadImagesKey, value);
  }

  Future<void> setSkipEventVerification(bool value) async {
    skipEventVerification.value = value;
    await _storageService.saveSetting(skipEventVerificationKey, value);

    // Hot-swap the verifier
    final switchableVerifier = Get.find<SwitchableVerifier>();
    if (value) {
      switchableVerifier.setDelegate(NoVerifier());
    } else {
      switchableVerifier.setDelegate(
        kIsWeb ? Bip340EventVerifier() : RustEventVerifier(),
      );
    }
  }

  Future<void> setEmailSignature(String value) async {
    emailSignature.value = value;
    await _storageService.saveSetting(_signatureKey, value);
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
    Get.changeThemeMode(value);
    await _storageService.saveSetting(themeModeKey, value.index);
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
}
