import 'package:get/get.dart';

import '../services/storage_service.dart';

class SettingsController extends GetxController {
  final _storageService = Get.find<StorageService>();

  static const _showRawEmailKey = 'show_raw_email';
  static const _alwaysLoadImagesKey = 'always_load_images';

  final showRawEmail = false.obs;
  final alwaysLoadImages = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    showRawEmail.value =
        await _storageService.getSetting<bool>(_showRawEmailKey) ?? false;
    alwaysLoadImages.value =
        await _storageService.getSetting<bool>(_alwaysLoadImagesKey) ?? false;
  }

  Future<void> setShowRawEmail(bool value) async {
    showRawEmail.value = value;
    await _storageService.saveSetting(_showRawEmailKey, value);
  }

  Future<void> setAlwaysLoadImages(bool value) async {
    alwaysLoadImages.value = value;
    await _storageService.saveSetting(_alwaysLoadImagesKey, value);
  }
}
