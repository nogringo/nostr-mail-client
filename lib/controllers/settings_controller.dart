import 'dart:async';

import 'package:get/get.dart';

import '../services/nostr_mail_service.dart';
import '../services/storage_service.dart';

class SettingsController extends GetxController {
  final _storageService = Get.find<StorageService>();
  StreamSubscription? _authSubscription;

  static const _showRawEmailKey = 'show_raw_email';
  static const _alwaysLoadImagesKey = 'always_load_images';
  static const _emailSignatureKey = 'email_signature';
  static const _backgroundImageKey = 'background_image';
  static const _defaultSignature =
      '--\nSent with Nmail\nhttps://github.com/nogringo/nostr-mail-client';

  final showRawEmail = false.obs;
  final alwaysLoadImages = false.obs;
  final emailSignature = _defaultSignature.obs;
  final backgroundImage = Rxn<String>();

  String? get _pubkey => Get.find<NostrMailService>().getPublicKey();

  String get _signatureKey =>
      _pubkey != null ? '${_emailSignatureKey}_$_pubkey' : _emailSignatureKey;

  String get _backgroundKey =>
      _pubkey != null ? '${_backgroundImageKey}_$_pubkey' : _backgroundImageKey;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _authSubscription = Get.find<NostrMailService>().ndk.accounts.stateChanges
        .listen((_) => _loadSettings());
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadSettings() async {
    showRawEmail.value =
        await _storageService.getSetting<bool>(_showRawEmailKey) ?? false;
    alwaysLoadImages.value =
        await _storageService.getSetting<bool>(_alwaysLoadImagesKey) ?? false;
    emailSignature.value =
        await _storageService.getSetting<String>(_signatureKey) ??
        _defaultSignature;
    backgroundImage.value = await _storageService.getSetting<String>(
      _backgroundKey,
    );
  }

  Future<void> setShowRawEmail(bool value) async {
    showRawEmail.value = value;
    await _storageService.saveSetting(_showRawEmailKey, value);
  }

  Future<void> setAlwaysLoadImages(bool value) async {
    alwaysLoadImages.value = value;
    await _storageService.saveSetting(_alwaysLoadImagesKey, value);
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
  }
}
