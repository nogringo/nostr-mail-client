import 'dart:typed_data';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// The gallery of saved backgrounds, kept in the Blossom cache.
class BackgroundsController extends GetxController {
  static const _cachedGalleryKey = 'background_gallery';

  /// Newest first, as background values.
  final savedImages = <String>[].obs;
  final isBusy = false.obs;

  SettingsController get _settings => Get.find<SettingsController>();

  @override
  void onInit() {
    super.onInit();
    loadSavedImages();
  }

  Future<void> loadSavedImages() async {
    try {
      final images = await _listCachedGallery();
      if (isClosed) return;
      savedImages.value = images;
    } catch (_) {
      if (!isClosed) savedImages.clear();
    }
  }

  Future<void> select(String? value) => _settings.setBackgroundImage(value);

  Future<PlatformFile?> pickImage() =>
      FilePicker.pickFile(type: FileType.image);

  Future<void> addFromUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      await select(null);
      return;
    }

    await _downloadToCache(context, url);
  }

  Future<void> deleteImage(BuildContext context, String value) async {
    final l = AppLocalizations.of(context);
    try {
      await _deleteCachedImage(value);
      if (_settings.backgroundImage.value == value) await select(null);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDeleteFailed);
      }
    }
  }

  Future<List<String>> _listCachedGallery() async {
    final cache = Get.find<BlossomCache>();
    final stored =
        await Get.find<StorageService>().getSetting<List>(_cachedGalleryKey) ??
        const [];

    // Removing an account deletes its background from the cache, not from
    // this list.
    final images = <String>[];
    for (final value in stored.cast<String>()) {
      final sha256 = BackgroundPreset.cachedImageSha256(value);
      if (sha256 != null && await cache.head(sha256) != null) {
        images.add(value);
      }
    }
    return images;
  }

  Future<void> _downloadToCache(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      (await decodeImageFromList(response.bodyBytes)).dispose();

      await _addToCachedGallery(
        response.bodyBytes,
        response.headers['content-type'],
      );
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundUrlError);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  Future<void> addPickedImage(BuildContext context, PlatformFile picked) async {
    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      await _addToCachedGallery(
        await picked.readAsBytes(),
        picked.extension != null ? 'image/${picked.extension}' : null,
      );
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundCopyFailed);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  Future<void> _addToCachedGallery(Uint8List bytes, String? type) async {
    final blob = await Get.find<BlossomCache>().put(
      bytes,
      type: type,
      pinBy: BlossomCache.defaultHolder,
    );
    final value = BackgroundPreset.cachedImageValue(blob.sha256);
    savedImages.remove(value);
    savedImages.insert(0, value);
    await _saveCachedGallery();
    await select(value);
  }

  Future<void> _deleteCachedImage(String value) async {
    final sha256 = BackgroundPreset.cachedImageSha256(value);
    if (sha256 != null) await Get.find<BlossomCache>().delete(sha256);
    savedImages.remove(value);
    await _saveCachedGallery();
  }

  Future<void> _saveCachedGallery() {
    return Get.find<StorageService>().saveSetting(
      _cachedGalleryKey,
      savedImages.toList(),
    );
  }
}
