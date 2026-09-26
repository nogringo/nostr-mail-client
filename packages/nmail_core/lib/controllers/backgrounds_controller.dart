import 'dart:io';
import 'dart:typed_data';

import 'package:blossom_cache/blossom_cache.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:nmail_core/controllers/settings_controller.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:nmail_core/models/background_preset.dart';
import 'package:nmail_core/services/storage_service.dart';
import 'package:nmail_core/utils/platform_helper.dart';
import 'package:nmail_core/utils/toast_helper.dart';

/// The gallery of saved backgrounds: files on disk on native builds, images in
/// the Blossom cache on web.
class BackgroundsController extends GetxController {
  static const _cachedGalleryKey = 'background_gallery';

  /// Newest first, as background values: file paths on native, cached images
  /// on web.
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
      final images = PlatformHelper.isNative
          ? await _listGalleryFiles()
          : await _listCachedGallery();
      if (isClosed) return;
      savedImages.value = images;
    } catch (_) {
      if (!isClosed) savedImages.clear();
    }
  }

  Future<void> select(String? value) => _settings.setBackgroundImage(value);

  Future<PlatformFile?> pickImage() =>
      FilePicker.pickFile(type: FileType.image);

  Future<void> addPickedImage(BuildContext context, PlatformFile picked) {
    return PlatformHelper.isNative
        ? _copyToGallery(context, picked)
        : _copyToCache(context, picked);
  }

  Future<void> addFromUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      await select(null);
      return;
    }

    await (PlatformHelper.isNative
        ? _downloadToGallery(context, url)
        : _downloadToCache(context, url));
  }

  Future<void> deleteImage(BuildContext context, String value) async {
    final l = AppLocalizations.of(context);
    try {
      await (PlatformHelper.isNative
          ? _deleteFile(value)
          : _deleteCachedImage(value));
      if (_settings.backgroundImage.value == value) await select(null);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDeleteFailed);
      }
    }
  }

  Future<List<String>> _listGalleryFiles() async {
    final dir = await _backgroundsDir();
    final files = await dir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    files.sort(
      (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
    );
    return [for (final file in files) file.path];
  }

  Future<void> _copyToGallery(BuildContext context, PlatformFile picked) async {
    final l = AppLocalizations.of(context);
    final sourcePath = picked.path;
    if (sourcePath == null) return;

    try {
      final dir = await _backgroundsDir();
      final saved = await File(sourcePath).copy(p.join(dir.path, picked.name));
      savedImages.remove(saved.path);
      savedImages.insert(0, saved.path);
      await select(saved.path);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundCopyFailed);
      }
    }
  }

  Future<void> _downloadToGallery(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    isBusy.value = true;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      var extension = url.split('.').last.split('?').first;
      if (extension.length > 4) {
        extension = response.headers['content-type']?.split('/').last ?? 'jpg';
      }

      final dir = await _backgroundsDir();
      final name = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final saved = File(p.join(dir.path, name));
      await saved.writeAsBytes(response.bodyBytes);

      savedImages.insert(0, saved.path);
      await select(saved.path);
    } catch (_) {
      if (context.mounted) {
        ToastHelper.error(context, l.settingsBackgroundDownloadFailed);
      }
    } finally {
      if (!isClosed) isBusy.value = false;
    }
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
    savedImages.remove(path);
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

  Future<void> _copyToCache(BuildContext context, PlatformFile picked) async {
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
      pinned: true,
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

  Future<Directory> _backgroundsDir() async {
    final appDir = await getApplicationSupportDirectory();
    final dir = Directory(
      p.join(appDir.path, SettingsController.backgroundsDirName),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
